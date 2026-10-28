import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';

IconData getBootstrapIcon(String? iconName) {
  switch (iconName) {
    case 'bi-heart-pulse':
      return BootstrapIcons.heart_pulse;

    case 'bi-house-door':
      return BootstrapIcons.house_door;

    case 'bi-door-open':
      return BootstrapIcons.door_open;

    case 'bi-wifi':
      return BootstrapIcons.wifi;

    case 'bi-book':
      return BootstrapIcons.book;

    case 'bi-mortarboard':
      return BootstrapIcons.mortarboard;

    case 'bi-trophy':
      return BootstrapIcons.trophy;

    case 'bi-gender-male':
      return BootstrapIcons.gender_male;

    case 'bi-gender-female':
      return BootstrapIcons.gender_female;

    case 'bi-people':
      return BootstrapIcons.people;

    case 'bi-buildings':
      return BootstrapIcons.buildings;

    case 'bi-gem':
      return BootstrapIcons.gem;

    case 'bi-heart-half':
      return BootstrapIcons.heart_half;

    default:
      return BootstrapIcons.grid;
  }
}

Widget getNavigation(String? iconName) {
  switch (iconName) {
    case 'bi-heart-pulse':
      return const GymBottomNavBarScreen();

    case 'bi-house-door':
      return const GymBottomNavBarScreen();

    case 'bi-door-open':
      return const RoomBottomNavBarScreen();

    case 'bi-wifi':
      return const RoomBottomNavBarScreen();

    case 'bi-book':
      return const RoomBottomNavBarScreen();

    case 'bi-mortarboard':
      return const RoomBottomNavBarScreen();

    case 'bi-trophy':
      return const RoomBottomNavBarScreen();

    case 'bi-laptop':
      return const RoomBottomNavBarScreen();

    default:
      return const RoomBottomNavBarScreen();
  }
}
