/// {@template openai_endpoints}
/// The class holding all endpoints for the API that are used.
/// {@endtemplate}
class OpenAIApisEndpoints {
  /// none.
  final completion = "/completions";

  /// none.
  final audio = "/audio";

  /// none.
  final chat = "/chat/completions";

  /// none.
  final edits = "/edits";

  /// none.
  final embeddings = "/embeddings";

  /// none.
  final files = "/files";

  /// none.
  final fineTunes = "/fine-tunes";

  /// none.
  final images = "/images";

  /// none.
  final models = "/models";

  /// none.
  final moderation = "/moderations";

  /// Responses API endpoint.
  final responses = "/responses";

  /// Conversations API endpoint.
  final conversations = "/conversations";

  /// Uploads API endpoint.
  final uploads = "/uploads";

  /// Vector Stores API endpoint.
  final vectorStores = "/vector_stores";

  /// Batches API endpoint.
  final batches = "/batches";

  /// Current Fine-tuning Jobs API endpoint.
  final fineTuningJobs = "/fine_tuning/jobs";

  /// Containers API endpoint.
  final containers = "/containers";

  /// Evals API endpoint.
  final evals = "/evals";

  /// Fine-tuning grader endpoint.
  final graders = "/fine_tuning/alpha/graders";

  /// Realtime API endpoint.
  final realtime = "wss://api.openai.com/v1/realtime";

  /// {@macro openai_endpoints}
  static const OpenAIApisEndpoints _instance = OpenAIApisEndpoints._();

  /// {@macro openai_endpoints}
  static OpenAIApisEndpoints get instance => _instance;

  /// {@macro openai_endpoints}
  const OpenAIApisEndpoints._();
}
