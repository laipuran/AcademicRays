/// Abstract class for a single step in a processing pipeline.
/// [I] is the input type, [O] is the output type.
abstract class PipelineStep<I, O> {
  final String name;

  PipelineStep(this.name);

  /// Executes the step's logic.
  Future<O> execute(I input);
}

/// Represents the current state of a pipeline execution.
enum PipelineStatus { idle, running, completed, failed }

/// Context to carry data across the pipeline steps.
class PipelineContext {
  final Map<String, dynamic> _data = {};

  void set(String key, dynamic value) => _data[key] = value;
  T? get<T>(String key) => _data[key] as T?;
}
