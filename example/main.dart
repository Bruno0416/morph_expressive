import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const MorphExampleApp());

/// A small, interactive tour of Morph's public APIs. No extra packages needed.
class MorphExampleApp extends StatelessWidget {
  const MorphExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    final morphTheme = MorphThemeData.light(seedColor: seed);

    return MaterialApp(
      title: 'Morph Expressive examples',
      theme: morphTheme.toThemeData(),
      // The builder keeps MorphTheme available inside modal routes, too.
      builder: (context, child) =>
          MorphTheme(data: morphTheme, child: child ?? const SizedBox.shrink()),
      home: const _ComponentExamples(),
    );
  }
}

class _ComponentExamples extends StatefulWidget {
  const _ComponentExamples();

  @override
  State<_ComponentExamples> createState() => _ComponentExamplesState();
}

class _ComponentExamplesState extends State<_ComponentExamples> {
  final TextEditingController _emailController = TextEditingController();
  final List<String> _items = <String>[
    'Try swipe actions',
    'Customize validation',
    'Explore the dialog',
  ];

  String _view = 'Movies';
  Set<String> _genres = <String>{'Drama'};
  bool _showEmailError = false;
  bool _errorIconAtPrefix = false;
  bool _saved = false;
  String _lastAction = 'Swipe an item left or right to reveal actions.';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final value = _emailController.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    setState(() => _showEmailError = !valid);
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
      _lastAction = 'Archived: $item';
    });
  }

  void _showDialog() {
    MorphDialog.show<void>(
      context,
      dialog: MorphDialog(
        title: 'Morph Dialog',
        icon: const Icon(MorphIcons.star),
        content: const Text(
          'Dialogs share the theme, rounded shapes and expressive motion '
          'used throughout Morph Expressive.',
        ),
        actions: <Widget>[
          MorphButton(
            style: MorphButtonStyle.tonal,
            label: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morph Expressive · v0.3.0')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'A few real, interactive public APIs. Change the selections, '
                    'validate the email and swipe the list items.',
                  ),
                  const SizedBox(height: 28),
                  _section(
                    context,
                    'MorphButton',
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        MorphButton(
                          icon: Icon(
                            _saved
                                ? MorphIcons.favorite
                                : MorphIcons.favorite_border,
                          ),
                          label: Text(_saved ? 'Saved' : 'Save'),
                          isSelected: _saved,
                          onPressed: () => setState(() => _saved = !_saved),
                        ),
                        MorphButton(
                          style: MorphButtonStyle.outlined,
                          label: const Text('Show dialog'),
                          onPressed: _showDialog,
                        ),
                      ],
                    ),
                  ),
                  _section(
                    context,
                    'MorphSegmentedToggle',
                    MorphSegmentedToggle<String>(
                      options: const <MorphSegmentedToggleOption<String>>[
                        MorphSegmentedToggleOption(
                          value: 'Movies',
                          label: 'Movies',
                        ),
                        MorphSegmentedToggleOption(
                          value: 'Series',
                          label: 'Series',
                        ),
                      ],
                      selected: _view,
                      onChanged: (next) => setState(() => _view = next),
                    ),
                  ),
                  _section(
                    context,
                    'MorphChipToggle · multiple selection',
                    MorphChipToggle<String>(
                      multiSelection: true,
                      options: const <MorphChipToggleOption<String>>[
                        MorphChipToggleOption(value: 'Drama', label: 'Drama'),
                        MorphChipToggleOption(value: 'Comedy', label: 'Comedy'),
                        MorphChipToggleOption(value: 'Sci-Fi', label: 'Sci-Fi'),
                      ],
                      selectedValues: _genres,
                      onSelectionChanged: (next) =>
                          setState(() => _genres = next),
                    ),
                  ),
                  _section(
                    context,
                    'MorphTextField · validation',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MorphTextField(
                          controller: _emailController,
                          variant: MorphTextFieldVariant.filled,
                          label: 'Email address',
                          placeholder: 'name@example.com',
                          leading: const Icon(MorphIcons.mail),
                          errorText: _showEmailError
                              ? 'Enter a valid email address.'
                              : null,
                          // Error icons are opt-in; this toggle demonstrates
                          // both prefix and suffix positions.
                          errorIcon: const Icon(MorphIcons.error),
                          errorIconPosition: _errorIconAtPrefix
                              ? MorphTextFieldErrorIconPosition.prefix
                              : MorphTextFieldErrorIconPosition.suffix,
                          onChanged: (_) {
                            if (_showEmailError) {
                              setState(() => _showEmailError = false);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        MorphTextField(
                          variant: MorphTextFieldVariant.outlined,
                          label: 'A note (outlined)',
                          placeholder: 'Optional',
                          supportingText: 'This field has no validation icon.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            MorphButton(
                              style: MorphButtonStyle.tonal,
                              label: const Text('Validate email'),
                              onPressed: _validateEmail,
                            ),
                            MorphButton(
                              style: MorphButtonStyle.outlined,
                              label: Text(
                                _errorIconAtPrefix
                                    ? 'Error icon: prefix'
                                    : 'Error icon: suffix',
                              ),
                              onPressed: () => setState(
                                () => _errorIconAtPrefix = !_errorIconAtPrefix,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _section(
                    context,
                    'MorphList · swipe actions',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MorphList(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return MorphListItem(
                              key: ValueKey<String>(item),
                              headline: item,
                              supportingText: 'Swipe to reveal action pills',
                              leading: const Icon(MorphIcons.star_outline),
                              // Reveal-only never removes the row implicitly.
                              swipe: MorphListItemSwipe(
                                mode: MorphListSwipeMode.reveal,
                                leading: <MorphListSwipeAction>[
                                  MorphListSwipeAction(
                                    icon: const Icon(MorphIcons.favorite),
                                    tooltip: 'Favorite',
                                    onPressed: () => setState(
                                      () => _lastAction = 'Favorited: $item',
                                    ),
                                  ),
                                ],
                                trailing: <MorphListSwipeAction>[
                                  MorphListSwipeAction(
                                    icon: const Icon(MorphIcons.archive),
                                    tooltip: 'Archive',
                                    onPressed: () => _removeItem(item),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(_lastAction),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
