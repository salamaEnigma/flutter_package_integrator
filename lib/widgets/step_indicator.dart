import 'package:flutter/material.dart';
import '../models/integration_state_model.dart';

class StepIndicator extends StatelessWidget {
  final IntegrationStep currentStep;
  final IntegrationStep? lastCompletedStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.lastCompletedStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps =
        IntegrationStep.values
            .where((step) => step != IntegrationStep.complete)
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final isCompleted =
                lastCompletedStep != null &&
                step.index <= lastCompletedStep!.index;
            final isCurrent = step == currentStep;

            return Row(
              children: [
                if (index > 0)
                  Container(
                    width: 20,
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCompleted
                                ? Colors.green
                                : (isCurrent ? Colors.blue : Colors.grey),
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStepName(step),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getStepName(IntegrationStep step) {
    switch (step) {
      case IntegrationStep.selectProject:
        return 'Select Project';
      case IntegrationStep.validateProject:
        return 'Validate';
      case IntegrationStep.collectApiKeys:
        return 'API Keys';
      case IntegrationStep.addPackageDependency:
        return 'Add Package';
      case IntegrationStep.runPubGet:
        return 'Pub Get';
      case IntegrationStep.configureAndroid:
        return 'Android';
      case IntegrationStep.configureIOS:
        return 'iOS';
      case IntegrationStep.addExampleFile:
        return 'Example';
      case IntegrationStep.complete:
        return 'Complete';
    }
  }
}
