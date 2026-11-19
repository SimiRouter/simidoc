# Fine-tuning (unsupported)

Fine-tuning adjusts base-model behavior using training data and produces a new inference model. OpenAI offers supervised fine-tuning, direct preference optimization (DPO), and reinforcement fine-tuning; available methods depend on the chosen base model.

**SimiRouter does not currently support fine-tuning. These pages retain official OpenAI descriptions and direct examples requiring a key for the OpenAI project. Training may incur costs.**

OpenAI is winding down self-serve fine-tuning\: new users cannot create training jobs, while eligible existing users can create jobs until **January 6, 2027**, unless the base model shuts down earlier. Existing fine-tuned models remain available for inference only until their base model is deprecated. Eligibility, models, and dates can change; check the [official deprecation timeline](https\://developers.openai.com/api/docs/deprecations) before using this reference.

## Overview

Fine-tuning changes model weights, not prompts. It suits stable format constraints, fixed tone, and domain phrasing; it does not suit injecting knowledge that changes frequently, where retrieval or a longer system prompt costs less. Validate results with independent samples that did not participate in training.

| What you want to do          | Input                           | Output                            | Execution                                   |
| ---------------------------- | ------------------------------- | --------------------------------- | ------------------------------------------- |
| Train a specialized model    | JSONL training set + base model | Job object and `fine_tuned_model` | Asynchronous in the background; poll status |
| Observe the training process | Job ID                          | Event log and metrics             | Paginated queries, not SSE                  |
| Stop training                | Job ID                          | Cancelled job object              | Synchronous request                         |

## Core concepts

* **Base model**\: determines available methods and price. Different base models support different methods and parameters; choosing the wrong method is rejected at job creation.
* **Training and validation sets**\: JSONL with one conversation sample per line; the official minimum is 10, 50 is a common starting point, and 50 to 100 often shows clear improvement. Prepare the validation set separately and do not overlap it with the training set.
* **Job status**\: `queued`, `running`, `succeeded`, `failed`, `cancelled`. Only `succeeded` produces a new inference model; for `failed`, read `error` to tell whether the problem is data or parameters.
* **Output model**\: on success it returns a `fine_tuned_model` identifier; use it in place of the base model for inference. The model has an independent lifecycle; delete it yourself when needed.
* **Cost**\: training bills by token, and the output model may incur storage costs while retained; starting with a small sample and scaling up is more controllable than submitting all data at once.

## Endpoints and execution

| Operation                                        | Official request                                        | Execution                                                           |
| ------------------------------------------------ | ------------------------------------------------------- | ------------------------------------------------------------------- |
| [Create job (unsupported)](/simidoc/en/apps/api/pending/fine-tuning/create)             | `POST /v1/fine_tuning/jobs`                             | Returns a job object; asynchronous training runs in the background. |
| [Retrieve job details (unsupported)](/simidoc/en/apps/api/pending/fine-tuning/retrieve) | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}`         | Synchronously queries status, output model, and errors.             |
| [List jobs (unsupported)](/simidoc/en/apps/api/pending/fine-tuning/list)                | `GET /v1/fine_tuning/jobs`                              | Synchronous paginated query.                                        |
| [Retrieve job events (unsupported)](/simidoc/en/apps/api/pending/fine-tuning/events)    | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}/events`  | Paginated logs, not SSE.                                            |
| [Cancel job (unsupported)](/simidoc/en/apps/api/pending/fine-tuning/cancel)             | `POST /v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel` | Stops the job and returns its object.                               |

## Basic workflow

1. Prepare JSONL training data for the chosen fine-tuning method, and prepare a validation set separately.
2. Upload the data through the [official file-upload endpoint](/simidoc/en/apps/api/pending/files/upload) with `purpose=fine-tune`.
3. Choose a model that supports the method, create the job, and save the job ID.
4. Query the job status and events; `succeeded` means success, `failed` requires reading `error`, and `cancelled` means cancelled.
5. After training succeeds, use the returned `fine_tuned_model` for inference and validate results with an independent evaluation set.

Successful creation is not successful training, and cancellation does not reverse usage already incurred. Do not recreate the same training job merely because of a network timeout.

## Official references

* [OpenAI model optimization guide](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI supervised fine-tuning guide](https\://developers.openai.com/api/docs/guides/supervised-fine-tuning)
* [OpenAI Fine-tuning Jobs API](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs)