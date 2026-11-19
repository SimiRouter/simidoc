# Agent image calls are now included in protocol documentation

Agent tasks are now distributed across the three protocols. Each includes generation and editing templates, configuration, saving results, and failure handling, replacing a separate tutorial oriented toward OpenAI Images\:

* [Agent calls in OpenAI format](/simidoc/en/apps/api/images/openai)\: Images generation, JSON editing, and final-event checks.
* [Agent calls in Gemini native format](/simidoc/en/apps/api/images/gemini)\: GenerateContent image Parts, MIME types, and multi-turn context.
* [Agent calls in Qwen native format](/simidoc/en/apps/api/images/qwen)\: regional Alibaba Cloud configuration, native synchronous calls, and image URL downloads.

Agents still need local execution and response-inspection capabilities; these documents do not install remote Skills. Real requests may incur charges. Confirm the model, specifications, count, and output location before calling. Do not expose keys, overwrite files, or retry automatically. For interface, effect, and specification comparisons, see the [Image API overview](/simidoc/en/apps/api/images).