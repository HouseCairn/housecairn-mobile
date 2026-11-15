// SPDX-License-Identifier: AGPL-3.0-only

// The lists of choices of the model, with the codes of the web
// (`rooms/models.py`, `tasks/models.py`): the code is stored and synced, the
// words are in the ARB files (lib/ui/choices.dart).

/// `RoomKind` (`rooms/models.py:52-64`).
const roomKinds = [
  'living',
  'kitchen',
  'bathroom',
  'bedroom',
  'hallway',
  'office',
  'utility',
  'garage',
  'cellar',
  'attic',
  'outdoor',
  'other',
];

/// `ItemKind` (`rooms/models.py:119-121`).
const itemKinds = ['equipment', 'surface'];

/// `Trade` (`tasks/models.py:96-109`); `other` says which one in `trade_other`.
const trades = [
  'plumber',
  'electrician',
  'heating_engineer',
  'roofer',
  'carpenter',
  'painter',
  'mason',
  'gardener',
  'locksmith',
  'chimney_sweep',
  'other',
];

/// `PhotoCategory` (`rooms/models.py:200-206`).
const photoCategories = ['general', 'behind_walls', 'before', 'after', 'other'];

/// Phone numbers (`PHONE_PATTERN`, `tasks/models.py:112`).
final phonePattern = RegExp(r'^[0-9+()./ -]{3,40}$');

/// What Django's `EmailField` accepts, close enough for a phone: something, an
/// `@`, a domain with a dot, no space.
final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Longest address of a contractor (`ADDRESS_MAX_LENGTH`).
const addressMaxLength = 400;

/// Longest notes field (`NOTES_MAX_LENGTH`).
const notesMaxLength = 4000;

/// Links of an item (`MAX_LINKS`).
const maxLinks = 10;

/// Photos of a room or an item (`MAX_PHOTOS_PER_TARGET`).
const maxPhotosPerTarget = 30;
