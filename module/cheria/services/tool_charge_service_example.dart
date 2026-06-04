/// Tool Charge Service - Usage Examples
///
/// This file demonstrates how to use the tool charge system
/// for tool-based applications with fixed cost per use.

import 'package:flutter/material.dart';
import 'tool_charge_service.dart';
import '../widgets/badges/cost_badge.dart';
import '../router/app_router_extension.dart';

/* Example 1: Basic Tool Execution with Charge
 *
 * Use this pattern for tools that need to charge a fixed amount
 * after successful completion.
 */
class BasicToolExample extends StatefulWidget {
  const BasicToolExample({super.key});

  @override
  State<BasicToolExample> createState() => _BasicToolExampleState();
}

class _BasicToolExampleState extends State<BasicToolExample> {
  // Define fixed cost for this tool (constant at code generation time)
  static const int toolCost = 10;

  final ToolChargeService _chargeService = ToolChargeService.instance;

  bool _isProcessing = false;

  Future<void> _handleToolExecution() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Method 1: Using executeWithCharge (recommended)
      final success = await _chargeService.executeWithCharge(
        cost: toolCost,
        context: context,
        toolExecutor: () async {
          // Execute your tool service here
          // Return true if successful, false if failed
          return await _executeMyToolService();
        },
        onSuccess: () {
          // Handle success (result already saved)
          _showResult();
        },
        onFailure: () {
          // Handle failure (no charge applied)
          // SmartDialog.showToast('Tool execution failed');
        },
      );

      if (success) {
        // Tool completed and charged successfully
        print('Tool executed and charged successfully');
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<bool> _executeMyToolService() async {
    // Simulate tool service call
    await Future.delayed(const Duration(seconds: 2));

    // In real implementation:
    // 1. Call your AI/service API
    // 2. Parse and validate response
    // 3. Save result to storage/history
    // 4. Return true only if all steps succeed

    return true; // Return true if successful
  }

  void _showResult() {
    // Display result to user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tool Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show cost to user (UX requirement)
            const CostBadge(cost: toolCost),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isProcessing ? null : _handleToolExecution,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Execute Tool'),
            ),
          ],
        ),
      ),
    );
  }
}

/* Example 2: Manual Balance Check and Charge
 *
 * Use this pattern when you need more control over the flow
 */
class ManualChargeExample extends StatelessWidget {
  const ManualChargeExample({super.key});

  static const int toolCost = 25;

  Future<void> _handleToolUse(BuildContext context) async {
    final chargeService = ToolChargeService.instance;

    // Step 1: Check balance before service call
    final hasBalance = await chargeService.validateBalanceBeforeUse(
      cost: toolCost,
      context: context,
    );

    if (!hasBalance) {
      // User saw dialog and either went to store or cancelled
      return;
    }

    // Step 2: Execute tool service
    final success = await _callToolService();

    if (!success) {
      // Service failed - NO charge applied
      // SmartDialog.showToast('Service failed, no charge applied');
      return;
    }

    // Step 3: Charge only after successful result
    final charged = chargeService.chargeAfterSuccess(toolCost);

    if (charged) {
      // Success - result shown and charge applied
      // SmartDialog.showToast('Success! Charged: $toolCost coins');
    }
  }

  Future<bool> _callToolService() async {
    // Your tool service implementation
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleToolUse(context),
      child: const CostButtonLabel(cost: toolCost),
    );
  }
}

/* Example 3: Tool with Cost Confirmation Dialog
 *
 * Use this for expensive tools to show confirmation before charging
 */
class ToolWithConfirmationExample extends StatefulWidget {
  const ToolWithConfirmationExample({super.key});

  @override
  State<ToolWithConfirmationExample> createState() =>
      _ToolWithConfirmationExampleState();
}

class _ToolWithConfirmationExampleState
    extends State<ToolWithConfirmationExample> {
  static const int toolCost = 100;

  Future<void> _executeWithConfirmation(BuildContext context) async {
    final chargeService = ToolChargeService.instance;

    // Show confirmation dialog
    final confirmed = await chargeService.showChargeConfirmation(
      context: context,
      cost: toolCost,
      toolName: 'Premium Tool',
    );

    if (!confirmed) return;

    // Proceed with execution
    final success = await chargeService.executeWithCharge(
      cost: toolCost,
      context: context,
      toolExecutor: () => _executeTool(),
    );

    if (success) {
      // SmartDialog.showToast('Tool executed successfully!');
    }
  }

  Future<bool> _executeTool() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _executeWithConfirmation(context),
      child: const Text('Execute Premium Tool'),
    );
  }
}

/* Example 4: Using CostBadge Variants
 *
 * Different badge styles for different UI contexts
 */
class CostBadgeVariantsExample extends StatelessWidget {
  const CostBadgeVariantsExample({super.key});

  static const int cost = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard badge (default)
        const CostBadge(cost: cost, style: CostBadgeStyle.standard),

        const SizedBox(height: 8),

        // Compact badge
        const CostBadge(cost: cost, style: CostBadgeStyle.compact),

        const SizedBox(height: 8),

        // Outlined badge
        const CostBadge(cost: cost, style: CostBadgeStyle.outlined),

        const SizedBox(height: 8),

        // Minimal badge
        const CostBadge(cost: cost, style: CostBadgeStyle.minimal),

        const SizedBox(height: 8),

        // Custom label
        const CostBadge(
          cost: cost,
          label: 'Price: $cost coins',
        ),

        const SizedBox(height: 8),

        // Inline cost text
        const CostText(
          cost: cost,
          prefix: 'Total: ',
          suffix: ' coins',
        ),
      ],
    );
  }
}

/* Example 5: Integration with Tool Page
 *
 * Complete example showing a tool page with charging
 */
class ToolPageExample extends StatefulWidget {
  const ToolPageExample({super.key});

  @override
  State<ToolPageExample> createState() => _ToolPageExampleState();
}

class _ToolPageExampleState extends State<ToolPageExample> {
  // Fixed cost constant (defined at code generation time)
  static const int toolCost = 20;

  final ToolChargeService _chargeService = ToolChargeService.instance;

  String _result = '';
  bool _isProcessing = false;

  Future<void> _runTool() async {
    setState(() {
      _isProcessing = true;
      _result = '';
    });

    final success = await _chargeService.executeWithCharge(
      cost: toolCost,
      context: context,
      toolExecutor: () async {
        // Execute tool service
        return await _processToolRequest();
      },
      onSuccess: () {
        setState(() {
          _result = 'Tool result here...';
        });
      },
    );

    setState(() {
      _isProcessing = false;
    });

    if (!success) {
      // SmartDialog.showToast('Tool execution failed');
    }
  }

  Future<bool> _processToolRequest() async {
    // Simulate tool processing
    await Future.delayed(const Duration(seconds: 2));

    // In real implementation:
    // 1. Validate input
    // 2. Call AI service API
    // 3. Parse response
    // 4. Save to history if needed
    // 5. Return true only if all succeed

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show cost prominently
            const CostBadge(
              cost: toolCost,
              style: CostBadgeStyle.standard,
            ),

            const SizedBox(height: 24),

            // Execute button
            ElevatedButton(
              onPressed: _isProcessing ? null : _runTool,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Run Tool'),
            ),

            const SizedBox(height: 24),

            // Result display
            if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* Key Implementation Points:
 *
 * 1. Define cost as constant at class level
 * 2. Show cost to user before execution (CostBadge)
 * 3. Use executeWithCharge for automatic flow
 * 4. Return true only after result is saved/confirmed
 * 5. Never charge before service completes successfully
 *
 * Testing scenarios:
 * - Balance sufficient, success → charge once
 * - Balance sufficient, failure → no charge
 * - Balance insufficient → dialog with "Get Coins" button
 */
