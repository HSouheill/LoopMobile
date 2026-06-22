import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand presentation for a social platform: either a brand-logo SVG asset
/// (tinted with [color]) or, for unknown platforms, a fallback Material icon.
class SocialIconData {
  /// Path to the brand SVG under assets/social_icons/, or null for the fallback.
  final String? assetPath;

  /// Fallback Material icon, used when [assetPath] is null.
  final IconData fallbackIcon;

  /// Brand color used to tint the logo / fallback icon.
  final Color color;

  const SocialIconData({
    this.assetPath,
    this.fallbackIcon = Icons.link,
    required this.color,
  });
}

/// Maps a social-link name (e.g. "facebook", "Instagram") to its branded logo
/// and color. Unknown names fall back to a generic link icon.
///
/// Brand logos are bundled as SVG assets (see assets/social_icons/) instead of
/// an icon font. Asset images are NOT subject to Flutter's icon tree-shaking, so
/// a plain `flutter build` is safe — unlike FontAwesome, whose IconData
/// subclasses got stripped in release and crashed these pages.
SocialIconData socialIconFor(String platformName) {
  switch (platformName.toLowerCase().trim()) {
    case 'facebook':
      return const SocialIconData(
          assetPath: 'assets/social_icons/facebook.svg', color: Color(0xFF1877F2));
    case 'instagram':
      return const SocialIconData(
          assetPath: 'assets/social_icons/instagram.svg', color: Color(0xFFE4405F));
    case 'twitter':
      return const SocialIconData(
          assetPath: 'assets/social_icons/twitter.svg', color: Color(0xFF000000));
    case 'linkedin':
      return const SocialIconData(
          assetPath: 'assets/social_icons/linkedin.svg', color: Color(0xFF0077B5));
    case 'youtube':
      return const SocialIconData(
          assetPath: 'assets/social_icons/youtube.svg', color: Color(0xFFFF0000));
    case 'tiktok':
      return const SocialIconData(
          assetPath: 'assets/social_icons/tiktok.svg', color: Color(0xFF000000));
    case 'snapchat':
      return const SocialIconData(
          assetPath: 'assets/social_icons/snapchat.svg', color: Color(0xFFFFA800));
    case 'pinterest':
      return const SocialIconData(
          assetPath: 'assets/social_icons/pinterest.svg', color: Color(0xFFBD081C));
    case 'reddit':
      return const SocialIconData(
          assetPath: 'assets/social_icons/reddit.svg', color: Color(0xFFFF4500));
    case 'discord':
      return const SocialIconData(
          assetPath: 'assets/social_icons/discord.svg', color: Color(0xFF5865F2));
    case 'telegram':
      return const SocialIconData(
          assetPath: 'assets/social_icons/telegram.svg', color: Color(0xFF0088CC));
    case 'whatsapp':
      return const SocialIconData(
          assetPath: 'assets/social_icons/whatsapp.svg', color: Color(0xFF25D366));
    default:
      return const SocialIconData(fallbackIcon: Icons.link, color: Colors.grey);
  }
}

/// Renders the brand logo for [platformName] at [size], tinted with its brand
/// color. Falls back to a Material icon for unknown platforms.
Widget socialIconWidget(String platformName, {double size = 24}) {
  final data = socialIconFor(platformName);
  if (data.assetPath == null) {
    return Icon(data.fallbackIcon, color: data.color, size: size);
  }
  return SvgPicture.asset(
    data.assetPath!,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(data.color, BlendMode.srcIn),
  );
}
