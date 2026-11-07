import { onRequest } from "firebase-functions/v2/https";
import Anthropic from "@anthropic-ai/sdk";

// Bounded-depth schema: one level of subtasks, matching the Flutter app's
// ChecklistItem model. json_schema does not support recursive schemas, so
// depth is fixed here rather than left open-ended.
const CHECKLIST_SCHEMA = {
  type: "object",
  properties: {
    items: {
      type: "array",
      items: {
        type: "object",
        properties: {
          title: { type: "string" },
          subtasks: {
            type: "array",
            items: {
              type: "object",
              properties: {
                title: { type: "string" },
              },
              required: ["title"],
              additionalProperties: false,
            },
          },
        },
        required: ["title", "subtasks"],
        additionalProperties: false,
      },
    },
  },
  required: ["items"],
  additionalProperties: false,
} as const;

const MAX_INPUT_CHARS = 20000;

export const generateChecklist = onRequest(
  { secrets: ["ANTHROPIC_API_KEY", "SHARED_SECRET"] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const expectedSecret = process.env.SHARED_SECRET;
    const authHeader = req.get("Authorization");
    if (expectedSecret && authHeader !== `Bearer ${expectedSecret}`) {
      res.status(401).send("Unauthorized");
      return;
    }

    const text = req.body?.text;
    if (typeof text !== "string" || text.trim().length === 0) {
      res.status(400).send("Missing 'text' field");
      return;
    }
    if (text.length > MAX_INPUT_CHARS) {
      res.status(400).send(`'text' exceeds ${MAX_INPUT_CHARS} characters`);
      return;
    }

    try {
      const client = new Anthropic();
      const response = await client.messages.create({
        model: "claude-haiku-4-5",
        max_tokens: 4096,
        messages: [
          {
            role: "user",
            content:
              "Extract a checklist from the following text. Break it into " +
              "clear, actionable items in the order they appear. Where the " +
              "text has a natural sub-grouping (e.g. a module with sub-" +
              "resources, a step with sub-steps), nest those as subtasks — " +
              "only one level deep. Do not invent items the text doesn't " +
              "imply.\n\nText:\n" +
              text,
          },
        ],
        output_config: {
          format: {
            type: "json_schema",
            schema: CHECKLIST_SCHEMA,
          },
        },
      });

      const textBlock = response.content.find((block) => block.type === "text");
      if (!textBlock || textBlock.type !== "text") {
        res.status(502).send("Model returned no text content");
        return;
      }

      const parsed = JSON.parse(textBlock.text);
      res.status(200).json(parsed);
    } catch (err) {
      console.error("generateChecklist failed", err);
      res.status(500).send("Generation failed");
    }
  },
);
