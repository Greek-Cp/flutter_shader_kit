// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


/// Utility class for shader-related operations
class ShaderUtils {
  /// Returns the correct shader asset path based on platform
  ///
  /// All platforms use packages prefix when shader is from package
  static String getShaderAssetPath(String shaderName) {
    // All platforms use packages prefix for package shaders
    return 'packages/flutter_shader_kit/shaders/$shaderName';
  }
}
