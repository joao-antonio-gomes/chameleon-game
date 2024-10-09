/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const logger = require("firebase-functions/logger");
const {OpenAI} = require("openai");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// functions/index.js (ou index.ts para TypeScript)
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const assistantId = "asst_7Def8M08JcePEukjUnCDjfXl";

exports.getTheme = functions.https.onCall(async (data, context) => {
  // Autenticação opcional
  if (!context.auth) {
    logger.error("Usuário não autenticado.");
    throw new functions.https.HttpsError("unauthenticated",
        "Usuário não autenticado.");
  }

  if (!data.roomId) {
    logger.error("roomId é obrigatório.");
    throw new functions.https.HttpsError("invalid-argument",
        "roomId é obrigatório.");
  }

  const openai = new OpenAI({
    apiKey: process.env.CHAT_GPT_KEY,
  });

  // If thread is not created
  if (!data.thread) {
    logger.info("Thread não encontrada. Criando uma nova thread.");

    const stream = await openai.beta.threads.createAndRun(
        {
          assistant_id: assistantId,
          thread: {
            messages: [
              {role: "user", content: "Gere um tema para mim."},
            ],
          },
          stream: true,
        },
    );

    let threadId;
    for await (const event of stream) {
      if (event.event === "thread.created") {
        threadId = event.data.id;
      }
    }

    logger.info(`Thread ${threadId} criada.`);

    const threadMessages = await openai.beta.threads.messages.list(
        threadId,
    );

    const lastMessageThemeContent =
        threadMessages.data[0].content[0].text.value;
    const lastMessageThemeJson = JSON.parse(lastMessageThemeContent);

    logger.info(`Tema gerado: ${lastMessageThemeJson.theme}`);

    return {
      thread: threadId,
      theme: lastMessageThemeJson.theme,
      category: lastMessageThemeJson.category,
    };
  }

  // If thread is already
  logger.info(`Thread ${data.thread} encontrada. Enviando mensagem.`);

  await openai.beta.threads.messages.create(
      data.thread,
      {role: "user", content: "Gere um tema para mim."},
  );

  logger.info(`Mensagem enviada para thread ${data.thread}.`);

  const run = await openai.beta.threads.runs.stream(data.thread, {
    assistant_id: assistantId,
  });

  logger.info(`Thread ${data.thread} em execução.`);

  for await (const event of run) {
    if (event.event === "thread.run.completed") break;
  }

  logger.info(`Thread ${data.thread} finalizada.`);

  const threadMessages = await openai.beta.threads.messages.list(
      data.thread,
  );

  const lastMessageThemeContent = threadMessages.data[0].content[0].text.value;
  const lastMessageThemeJson = JSON.parse(lastMessageThemeContent);

  logger.info(`Tema gerado: ${lastMessageThemeJson.theme}`);

  return {
    thread: data.thread,
    theme: lastMessageThemeJson.theme,
    category: lastMessageThemeJson.category,
  };
});
