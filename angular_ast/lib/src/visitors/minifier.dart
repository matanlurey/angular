import '../ast.dart';

import 'recursive.dart';

/// Implements a [TemplateAstVisitor] that removes unnecessary whitespace.
///
/// This is meant to implement the `preserveWhitespace: false` mechanic of
/// the AngularDart framework, and is roughly based on the existing tool
/// `HTMLMinifier`: https://github.com/kangax/html-minifier/.
class TemplateMinifier extends RecursiveTemplateAstVisitor<bool> {
  /// Collapse whitespace that contributes to text nodes in a document tree.
  ///
  /// It doesn't affect significant white space, e.g. in the contents of
  /// elements like `<SCRIPT>`, `<STYLE>`, `<PRE>`, or `<TEXTAREA>`. This
  /// modification **has side effects**, and can significantly change document
  /// representation:
  /// ```html
  /// <span>Foo</span> <span>Bar</span>
  /// ```
  ///
  /// ... is usually displayed as `Foo Bar` in browsers, with a space character.
  /// This minifier will attempt to keep this type of whitespace in order to
  /// avoid confusing users around the output.
  final collapseWhitespace = true;

  /// Removes HTML comments from the template.
  ///
  /// If `true`, `<!--` tags are removed.
  ///
  /// **NOTE**: Not yet supported.
  final removeComments = false;

  const TemplateMinifier();

  @override
  TemplateAst visitElement(ElementAst astNode, [_]) {
    if (collapseWhitespace &&
        _canTrimWhitespace(astNode.name) &&
        _hasTextNodes(astNode)) {
      return new ElementAst.from(
        astNode,
        astNode.name,
        visit(astNode.closeComplement),
        attributes: astNode.attributes,
        childNodes: visitAll(astNode.childNodes, true),
        events: astNode.events,
        properties: astNode.properties,
        references: astNode.references,
        bananas: astNode.bananas,
        stars: astNode.stars,
        annotations: astNode.annotations,
      );
    }
    return super.visitElement(astNode);
  }

  @override
  TemplateAst visitText(TextAst astNode, [bool shouldCollapse = false]) {
    if (shouldCollapse) {
      // This is ~mostly a no-op right now.
      return new TextAst.from(
        astNode,
        _collapseWhitespace(astNode.value),
      );
    }
    return super.visitText(astNode);
  }

  static bool _hasTextNodes(ElementAst astNode) =>
      astNode.childNodes.any((c) => c is TextAst);

  static bool _canTrimWhitespace(String tagName) {
    switch (tagName.toUpperCase()) {
      case 'SCRIPT':
      case 'STYLE':
      case 'PRE':
      case 'TEXTAREA':
        return false;
      default:
        return true;
    }
  }

  static final _lineBreaks1 = new RegExp(r'^[ \n\r\t\f]*?[\n\r][ \n\r\t\f]*');
  static final _lineBreaks2 = new RegExp(r'[ \n\r\t\f]*?[\n\r][ \n\r\t\f]*$');

  static final _trimLeftFindSpaces = new RegExp(
    r'[ \n\r\t\f\xA0]+$',
    multiLine: true,
  );
  static final _trimLeftRemoveSpaces1 = new RegExp(
    r'[^\xA0]+(\xA0+)',
    multiLine: true,
  );
  static final _trimLeftRemoveSpaces2 = new RegExp(
    r'[^\xA0]+$',
    multiLine: true,
  );

  static String _collapseWhitespace(
    String text, {
    bool preserveLineBreaks: false,
    bool trimLeft: false,
    bool trimRight: false,
    bool collapseAll: false,
  }) {
    var lineBreakBefore = '';
    var lineBreakAfter = '';
    if (preserveLineBreaks) {
      text = text.replaceAllMapped(_lineBreaks1, (_) {
        lineBreakBefore = '\n';
        return '';
      }).replaceAllMapped(_lineBreaks2, (_) {
        lineBreakAfter = '\n';
        return '';
      });
    }

    if (trimLeft) {
      text = text.replaceAllMapped(
          _trimLeftFindSpaces,
          ((match) => match
              .group(0)
              .replaceAll(_trimLeftRemoveSpaces1, ' ${match.group(1)}')
              .replaceAll(_trimLeftRemoveSpaces2, '')));
    }
    if (collapseAll) {
      text = _collapseWhitespaceAll(text);
    }
    return '$lineBreakBefore$text$lineBreakAfter';
  }

  static final _collapseAllFindWhitespace = new RegExp(r'[ \n\r\t\f\xA0]+');
  static final _collapseAllReplaceWhitespace = new RegExp(r'(^|\xA0+)[^\xA0]+');

  static String _collapseWhitespaceAll(String text) => text.replaceAllMapped(
      _collapseAllFindWhitespace,
      (match) => match.group(0) == '\t'
          ? '\t'
          : match
              .group(0)
              .replaceAll(_collapseAllReplaceWhitespace, '${match.group(1)} '));
}
