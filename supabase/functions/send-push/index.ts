// Edge Function send-push: envia um aviso da fila `push_notifications` pelo
// Firebase Cloud Messaging (API HTTP v1).
//
// Quem chama: o gatilho `trg_push_notifications_disparar` (pg_net), com o corpo
// { "id": "<uuid do aviso>" }. A função NÃO confia no corpo além do id: lê o
// aviso no banco, envia só se ainda não foi enviado e marca `sent_at`. Por isso
// pode rodar com "Enforce JWT verification" desligado.
//
// Segredos (Supabase → Edge Functions → Secrets):
//   FIREBASE_SERVICE_ACCOUNT = JSON da conta de serviço do projeto lummy-dce58
//   (Firebase → Configurações do projeto → Contas de serviço → Gerar nova chave).
// SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY já existem no ambiente da função.

import { createClient } from "jsr:@supabase/supabase-js@2";

type ContaDeServico = {
  project_id: string;
  client_email: string;
  private_key: string;
};

type Aviso = {
  id: string;
  user_id: string;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
  sent_at: string | null;
};

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

let tokenGoogle: { valor: string; expiraEm: number } | null = null;

function base64Url(bytes: Uint8Array | string): string {
  const b = typeof bytes === "string" ? new TextEncoder().encode(bytes) : bytes;
  let s = "";
  for (const c of b) s += String.fromCharCode(c);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemParaBytes(pem: string): Uint8Array {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

// Token OAuth do Google para o FCM (JWT assinado com a chave da conta de serviço).
async function obterTokenGoogle(conta: ContaDeServico): Promise<string> {
  const agora = Math.floor(Date.now() / 1000);
  if (tokenGoogle && tokenGoogle.expiraEm - 60 > agora) return tokenGoogle.valor;

  const cabecalho = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const corpo = base64Url(JSON.stringify({
    iss: conta.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: agora,
    exp: agora + 3600,
  }));
  const chave = await crypto.subtle.importKey(
    "pkcs8",
    pemParaBytes(conta.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const assinatura = new Uint8Array(
    await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      chave,
      new TextEncoder().encode(`${cabecalho}.${corpo}`),
    ),
  );
  const jwt = `${cabecalho}.${corpo}.${base64Url(assinatura)}`;

  const resposta = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!resposta.ok) {
    throw new Error(`token Google: ${resposta.status} ${await resposta.text()}`);
  }
  const json = await resposta.json();
  tokenGoogle = { valor: json.access_token, expiraEm: agora + (json.expires_in ?? 3600) };
  return tokenGoogle.valor;
}

// O FCM só aceita strings em `data`.
function dadosComoTexto(data: Record<string, unknown> | null): Record<string, string> {
  const saida: Record<string, string> = {};
  for (const [k, v] of Object.entries(data ?? {})) {
    if (v !== null && v !== undefined) saida[k] = String(v);
  }
  return saida;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("método não permitido", { status: 405 });

  let id: string | undefined;
  try {
    id = (await req.json())?.id;
  } catch {
    // corpo inválido
  }
  if (!id) return new Response("faltou id", { status: 400 });

  const { data: aviso, error } = await supabase
    .from("push_notifications")
    .select("id, user_id, title, body, data, sent_at")
    .eq("id", id)
    .maybeSingle<Aviso>();
  if (error) return new Response(`erro ao ler aviso: ${error.message}`, { status: 500 });
  // Aviso inexistente ou já enviado: nada a fazer (chamada repetida ou forjada).
  if (!aviso || aviso.sent_at) return new Response("ok", { status: 200 });

  const { data: aparelhos } = await supabase
    .from("push_tokens")
    .select("token, platform")
    .eq("user_id", aviso.user_id);

  // Marca antes de enviar: se a função for chamada duas vezes, só uma envia.
  const { data: marcado } = await supabase
    .from("push_notifications")
    .update({ sent_at: new Date().toISOString() })
    .eq("id", aviso.id)
    .is("sent_at", null)
    .select("id");
  if (!marcado || marcado.length === 0) return new Response("ok", { status: 200 });

  if (!aparelhos || aparelhos.length === 0) {
    return new Response("sem aparelhos", { status: 200 });
  }

  const conta: ContaDeServico = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}");
  if (!conta.private_key) return new Response("FIREBASE_SERVICE_ACCOUNT ausente", { status: 500 });
  const tokenGoogleAtual = await obterTokenGoogle(conta);
  const url = `https://fcm.googleapis.com/v1/projects/${conta.project_id}/messages:send`;

  let enviados = 0;
  for (const aparelho of aparelhos) {
    const resposta = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${tokenGoogleAtual}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: aparelho.token,
          notification: { title: aviso.title, body: aviso.body },
          data: dadosComoTexto(aviso.data),
          android: {
            priority: "HIGH",
            notification: { channel_id: "lummy_push", sound: "default" },
          },
          apns: { payload: { aps: { sound: "default" } } },
        },
      }),
    });
    if (resposta.ok) {
      enviados++;
      continue;
    }
    const erro = await resposta.text();
    // Token que não existe mais (app desinstalado, outro aparelho): remove.
    if (resposta.status === 404 || erro.includes("UNREGISTERED")) {
      await supabase.from("push_tokens").delete().eq("token", aparelho.token);
    }
    console.warn(`FCM ${resposta.status} para ${aparelho.platform}: ${erro}`);
  }

  return new Response(JSON.stringify({ enviados }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
