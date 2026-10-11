---
ai-generated: 100% - GenAI OTel span spec diff analysis
lab3_genai_diff:
  instrumentation: "opentelemetry-instrumentation-openai 0.35.0"
  spec_ref: "semantic-conventions@v1.41.1"
  attributes:
    - name: gen_ai.operation.name
      emitted: true
      in_spec: true
      stability: development
    - name: gen_ai.request.model
      emitted: true
      in_spec: true
      stability: development
    - name: gen_ai.response.model
      emitted: true
      in_spec: true
      stability: development
    - name: gen_ai.usage.input_tokens
      emitted: true
      in_spec: true
      stability: development
    - name: gen_ai.usage.output_tokens
      emitted: true
      in_spec: true
      stability: development
---
<!-- ai-generated: 100% - GenAI OTel span spec diff analysis -->

# GenAI Semantic Conventions Diff Analysis

## Declared Attributes vs Specification

The table below lists the 5 emitted OpenTelemetry attributes from `genai/spans.json` compared against the OTel Semantic Conventions for GenAI (`semantic-conventions@v1.41.1`):

| Attribute Key | Value in Spans | In Spec | Stability |
|---|---|---|---|
| `gen_ai.operation.name` | `"chat"` | true | development |
| `gen_ai.request.model` | `"gpt-4o"` | true | development |
| `gen_ai.response.model` | `"gpt-4o-2024-08-06"` | true | development |
| `gen_ai.usage.input_tokens` | `150` | true | development |
| `gen_ai.usage.output_tokens` | `50` | true | development |

## Summary
All 5 emitted attributes match the declared schema and agree with the OpenTelemetry GenAI semantic conventions specification snapshot.
