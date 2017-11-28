import 'package:meta/meta.dart';

/// A generated base view class for a given component or template.
///
/// This class should not be used directly. Instead see the following:
/// * [ComponentView]
/// * [DetachedView]
/// * [EmbeddedView]
abstract class View<T> {
  /// Whether the view has been destroyed.
  ///
  /// The public API for this property is [destroyed].
  bool _destroyed = false;

  /// Whether the view has been destroyed.
  bool get destroyed => _destroyed;
}

/// A view generated for a given component [T]'s template.
abstract class ComponentView<T> extends View<T> {

}

/// A view generated to encapsulate creating a given component [T].
///
/// This class is only used if the component is imperatively loaded, otherwise
/// much of this logic is reproduced in component or embedded that creates a
/// child component.
abstract class HostView<T> extends View<T> {

}

/// A view generated to encapsulate a `<template>` tag within component [T].
abstract class EmbeddedView<T> extends View<T> {

}
