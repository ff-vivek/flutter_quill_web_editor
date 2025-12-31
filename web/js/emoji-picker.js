/**
 * Emoji Picker Module
 * ===================
 * A lightweight emoji picker for the Quill editor
 */

// Common emoji categories with native emojis
const EMOJI_CATEGORIES = {
  recent: { icon: '🕐', name: 'Recent', emojis: [] },
  smileys: {
    icon: '😀',
    name: 'Smileys',
    emojis: [
      '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉',
      '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😜', '🤪', '😝',
      '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏', '😒',
      '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢',
      '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '🥸', '😎', '🤓',
      '🧐', '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳', '🥺', '😦', '😧',
      '😨', '😰', '😥', '😢', '😭', '😱', '😖', '😣', '😞', '😓', '😩', '😫',
      '🥱', '😤', '😡', '😠', '🤬', '😈', '👿', '💀', '☠️', '💩', '🤡', '👹',
      '👺', '👻', '👽', '👾', '🤖', '😺', '😸', '😹', '😻', '😼', '😽', '🙀',
      '😿', '😾'
    ]
  },
  gestures: {
    icon: '👋',
    name: 'Gestures',
    emojis: [
      '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘',
      '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍', '👎', '✊', '👊', '🤛',
      '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳', '💪', '🦾',
      '🦿', '🦵', '🦶', '👂', '🦻', '👃', '🧠', '🫀', '🫁', '🦷', '🦴', '👀',
      '👁️', '👅', '👄', '💋', '🩸'
    ]
  },
  people: {
    icon: '👨',
    name: 'People',
    emojis: [
      '👶', '🧒', '👦', '👧', '🧑', '👱', '👨', '🧔', '👩', '🧓', '👴', '👵',
      '🙍', '🙎', '🙅', '🙆', '💁', '🙋', '🧏', '🙇', '🤦', '🤷', '👮', '🕵️',
      '💂', '🥷', '👷', '🤴', '👸', '👳', '👲', '🧕', '🤵', '👰', '🤰', '🤱',
      '👼', '🎅', '🤶', '🦸', '🦹', '🧙', '🧚', '🧛', '🧜', '🧝', '🧞', '🧟',
      '💆', '💇', '🚶', '🧍', '🧎', '🏃', '💃', '🕺', '🕴️', '👯', '🧖', '🧗',
      '🤸', '🏌️', '🏇', '⛷️', '🏂', '🏋️', '🤼', '🤽', '🤾', '🤺', '⛹️', '🏊',
      '🚣', '🧘', '🛀', '🛌'
    ]
  },
  nature: {
    icon: '🐶',
    name: 'Nature',
    emojis: [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
      '🐷', '🐽', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤',
      '🐣', '🐥', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛',
      '🦋', '🐌', '🐞', '🐜', '🦟', '🦗', '🕷️', '🕸️', '🦂', '🐢', '🐍', '🦎',
      '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳',
      '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', '🦏', '🐪',
      '🐫', '🦒', '🦘', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏', '🐑', '🦙', '🐐',
      '🦌', '🐕', '🐩', '🦮', '🐕‍🦺', '🐈', '🐓', '🦃', '🦚', '🦜', '🦢', '🦩',
      '🕊️', '🐇', '🦝', '🦨', '🦡', '🦦', '🦥', '🐁', '🐀', '🐿️', '🦔'
    ]
  },
  food: {
    icon: '🍔',
    name: 'Food',
    emojis: [
      '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒',
      '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶️',
      '🫑', '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🥐', '🥯', '🍞', '🥖',
      '🥨', '🧀', '🥚', '🍳', '🧈', '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🦴',
      '🌭', '🍔', '🍟', '🍕', '🫓', '🥪', '🥙', '🧆', '🌮', '🌯', '🫔', '🥗',
      '🥘', '🫕', '🥫', '🍝', '🍜', '🍲', '🍛', '🍣', '🍱', '🥟', '🦪', '🍤',
      '🍙', '🍚', '🍘', '🍥', '🥠', '🥮', '🍢', '🍡', '🍧', '🍨', '🍦', '🥧',
      '🧁', '🍰', '🎂', '🍮', '🍭', '🍬', '🍫', '🍿', '🍩', '🍪', '🌰', '🥜',
      '🍯', '🥛', '🍼', '☕', '🫖', '🍵', '🧃', '🥤', '🧋', '🍶', '🍺', '🍻',
      '🥂', '🍷', '🥃', '🍸', '🍹', '🧉', '🍾', '🧊', '🥄', '🍴', '🍽️', '🥣',
      '🥡', '🥢', '🧂'
    ]
  },
  activities: {
    icon: '⚽',
    name: 'Activities',
    emojis: [
      '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🥏', '🎱', '🪀', '🏓',
      '🏸', '🏒', '🏑', '🥍', '🏏', '🪃', '🥅', '⛳', '🪁', '🏹', '🎣', '🤿',
      '🥊', '🥋', '🎽', '🛹', '🛼', '🛷', '⛸️', '🥌', '🎿', '⛷️', '🏂', '🪂',
      '🏋️', '🤼', '🤸', '🤾', '⛹️', '🤺', '🏊', '🚣', '🧗', '🚴', '🚵', '🎖️',
      '🏆', '🥇', '🥈', '🥉', '🏅', '🎪', '🤹', '🎭', '🩰', '🎨', '🎬', '🎤',
      '🎧', '🎼', '🎹', '🥁', '🪘', '🎷', '🎺', '🪗', '🎸', '🪕', '🎻', '🎲',
      '♟️', '🎯', '🎳', '🎮', '🎰', '🧩'
    ]
  },
  travel: {
    icon: '🚗',
    name: 'Travel',
    emojis: [
      '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🛻', '🚚',
      '🚛', '🚜', '🦯', '🦽', '🦼', '🛴', '🚲', '🛵', '🏍️', '🛺', '🚨', '🚔',
      '🚍', '🚘', '🚖', '🚡', '🚠', '🚟', '🚃', '🚋', '🚞', '🚝', '🚄', '🚅',
      '🚈', '🚂', '🚆', '🚇', '🚊', '🚉', '✈️', '🛫', '🛬', '🛩️', '💺', '🛰️',
      '🚀', '🛸', '🚁', '🛶', '⛵', '🚤', '🛥️', '🛳️', '⛴️', '🚢', '⚓', '🪝',
      '⛽', '🚧', '🚦', '🚥', '🚏', '🗺️', '🗿', '🗽', '🗼', '🏰', '🏯', '🏟️',
      '🎡', '🎢', '🎠', '⛲', '⛱️', '🏖️', '🏝️', '🏜️', '🌋', '⛰️', '🏔️', '🗻',
      '🏕️', '⛺', '🛖', '🏠', '🏡', '🏘️', '🏚️', '🏗️', '🏭', '🏢', '🏬', '🏣',
      '🏤', '🏥', '🏦', '🏨', '🏪', '🏫', '🏩', '💒', '🏛️', '⛪', '🕌', '🕍',
      '🛕', '🕋', '⛩️', '🛤️', '🛣️', '🗾', '🎑', '🏞️', '🌅', '🌄', '🌠', '🎇',
      '🎆', '🌇', '🌆', '🏙️', '🌃', '🌌', '🌉', '🌁'
    ]
  },
  objects: {
    icon: '💡',
    name: 'Objects',
    emojis: [
      '⌚', '📱', '📲', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '🖲️', '🕹️', '🗜️', '💽',
      '💾', '💿', '📀', '📼', '📷', '📸', '📹', '🎥', '📽️', '🎞️', '📞', '☎️',
      '📟', '📠', '📺', '📻', '🎙️', '🎚️', '🎛️', '🧭', '⏱️', '⏲️', '⏰', '🕰️',
      '⌛', '⏳', '📡', '🔋', '🔌', '💡', '🔦', '🕯️', '🪔', '🧯', '🛢️', '💸',
      '💵', '💴', '💶', '💷', '🪙', '💰', '💳', '💎', '⚖️', '🪜', '🧰', '🪛',
      '🔧', '🔨', '⚒️', '🛠️', '⛏️', '🪚', '🔩', '⚙️', '🪤', '🧱', '⛓️', '🧲',
      '🔫', '💣', '🧨', '🪓', '🔪', '🗡️', '⚔️', '🛡️', '🚬', '⚰️', '🪦', '⚱️',
      '🏺', '🔮', '📿', '🧿', '💈', '⚗️', '🔭', '🔬', '🕳️', '🩹', '🩺', '💊',
      '💉', '🩸', '🧬', '🦠', '🧫', '🧪', '🌡️', '🧹', '🪠', '🧺', '🧻', '🚽',
      '🚰', '🚿', '🛁', '🛀', '🧼', '🪥', '🪒', '🧽', '🪣', '🧴', '🛎️', '🔑',
      '🗝️', '🚪', '🪑', '🛋️', '🛏️', '🛌', '🧸', '🪆', '🖼️', '🪞', '🪟', '🛍️',
      '🛒', '🎁', '🎈', '🎏', '🎀', '🪄', '🎊', '🎉', '🎎', '🏮', '🎐', '🧧',
      '✉️', '📩', '📨', '📧', '💌', '📥', '📤', '📦', '🏷️', '🪧', '📪', '📫',
      '📬', '📭', '📮', '📯', '📜', '📃', '📄', '📑', '🧾', '📊', '📈', '📉',
      '🗒️', '🗓️', '📆', '📅', '🗑️', '📇', '🗃️', '🗳️', '🗄️', '📋', '📁', '📂',
      '🗂️', '🗞️', '📰', '📓', '📔', '📒', '📕', '📗', '📘', '📙', '📚', '📖',
      '🔖', '🧷', '🔗', '📎', '🖇️', '📐', '📏', '🧮', '📌', '📍', '✂️', '🖊️',
      '🖋️', '✒️', '🖌️', '🖍️', '📝', '✏️', '🔍', '🔎', '🔏', '🔐', '🔒', '🔓'
    ]
  },
  symbols: {
    icon: '❤️',
    name: 'Symbols',
    emojis: [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕',
      '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉️', '☸️',
      '✡️', '🔯', '🕎', '☯️', '☦️', '🛐', '⛎', '♈', '♉', '♊', '♋', '♌',
      '♍', '♎', '♏', '♐', '♑', '♒', '♓', '🆔', '⚛️', '🉑', '☢️', '☣️',
      '📴', '📳', '🈶', '🈚', '🈸', '🈺', '🈷️', '✴️', '🆚', '💮', '🉐', '㊙️',
      '㊗️', '🈴', '🈵', '🈹', '🈲', '🅰️', '🅱️', '🆎', '🆑', '🅾️', '🆘', '❌',
      '⭕', '🛑', '⛔', '📛', '🚫', '💯', '💢', '♨️', '🚷', '🚯', '🚳', '🚱',
      '🔞', '📵', '🚭', '❗', '❕', '❓', '❔', '‼️', '⁉️', '🔅', '🔆', '〽️',
      '⚠️', '🚸', '🔱', '⚜️', '🔰', '♻️', '✅', '🈯', '💹', '❇️', '✳️', '❎',
      '🌐', '💠', 'Ⓜ️', '🌀', '💤', '🏧', '🚾', '♿', '🅿️', '🛗', '🈳', '🈂️',
      '🛂', '🛃', '🛄', '🛅', '🚹', '🚺', '🚼', '⚧️', '🚻', '🚮', '🎦', '📶',
      '🈁', '🔣', 'ℹ️', '🔤', '🔡', '🔠', '🆖', '🆗', '🆙', '🆒', '🆕', '🆓',
      '0️⃣', '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '🔟',
      '🔢', '#️⃣', '*️⃣', '⏏️', '▶️', '⏸️', '⏯️', '⏹️', '⏺️', '⏭️', '⏮️', '⏩',
      '⏪', '⏫', '⏬', '◀️', '🔼', '🔽', '➡️', '⬅️', '⬆️', '⬇️', '↗️', '↘️',
      '↙️', '↖️', '↕️', '↔️', '↪️', '↩️', '⤴️', '⤵️', '🔀', '🔁', '🔂', '🔄',
      '🔃', '🎵', '🎶', '➕', '➖', '➗', '✖️', '♾️', '💲', '💱', '™️', '©️',
      '®️', '〰️', '➰', '➿', '🔚', '🔙', '🔛', '🔝', '🔜', '✔️', '☑️', '🔘',
      '🔴', '🟠', '🟡', '🟢', '🔵', '🟣', '⚫', '⚪', '🟤', '🔺', '🔻', '🔸',
      '🔹', '🔶', '🔷', '🔳', '🔲', '▪️', '▫️', '◾', '◽', '◼️', '◻️', '🟥',
      '🟧', '🟨', '🟩', '🟦', '🟪', '⬛', '⬜', '🟫', '🔈', '🔇', '🔉', '🔊',
      '🔔', '🔕', '📣', '📢', '💬', '💭', '🗯️', '♠️', '♣️', '♥️', '♦️', '🃏',
      '🎴', '🀄', '🕐', '🕑', '🕒', '🕓', '🕔', '🕕', '🕖', '🕗', '🕘', '🕙',
      '🕚', '🕛', '🕜', '🕝', '🕞', '🕟', '🕠', '🕡', '🕢', '🕣', '🕤', '🕥',
      '🕦', '🕧'
    ]
  },
  flags: {
    icon: '🏳️',
    name: 'Flags',
    emojis: [
      '🏳️', '🏴', '🏁', '🚩', '🏳️‍🌈', '🏳️‍⚧️', '🏴‍☠️', '🇦🇫', '🇦🇽', '🇦🇱',
      '🇩🇿', '🇦🇸', '🇦🇩', '🇦🇴', '🇦🇮', '🇦🇶', '🇦🇬', '🇦🇷', '🇦🇲', '🇦🇼',
      '🇦🇺', '🇦🇹', '🇦🇿', '🇧🇸', '🇧🇭', '🇧🇩', '🇧🇧', '🇧🇾', '🇧🇪', '🇧🇿',
      '🇧🇯', '🇧🇲', '🇧🇹', '🇧🇴', '🇧🇦', '🇧🇼', '🇧🇷', '🇮🇴', '🇻🇬', '🇧🇳',
      '🇧🇬', '🇧🇫', '🇧🇮', '🇰🇭', '🇨🇲', '🇨🇦', '🇮🇨', '🇨🇻', '🇧🇶', '🇰🇾',
      '🇨🇫', '🇹🇩', '🇨🇱', '🇨🇳', '🇨🇽', '🇨🇨', '🇨🇴', '🇰🇲', '🇨🇬', '🇨🇩',
      '🇨🇰', '🇨🇷', '🇨🇮', '🇭🇷', '🇨🇺', '🇨🇼', '🇨🇾', '🇨🇿', '🇩🇰', '🇩🇯',
      '🇩🇲', '🇩🇴', '🇪🇨', '🇪🇬', '🇸🇻', '🇬🇶', '🇪🇷', '🇪🇪', '🇸🇿', '🇪🇹',
      '🇪🇺', '🇫🇰', '🇫🇴', '🇫🇯', '🇫🇮', '🇫🇷', '🇬🇫', '🇵🇫', '🇹🇫', '🇬🇦',
      '🇬🇲', '🇬🇪', '🇩🇪', '🇬🇭', '🇬🇮', '🇬🇷', '🇬🇱', '🇬🇩', '🇬🇵', '🇬🇺',
      '🇬🇹', '🇬🇬', '🇬🇳', '🇬🇼', '🇬🇾', '🇭🇹', '🇭🇳', '🇭🇰', '🇭🇺', '🇮🇸',
      '🇮🇳', '🇮🇩', '🇮🇷', '🇮🇶', '🇮🇪', '🇮🇲', '🇮🇱', '🇮🇹', '🇯🇲', '🇯🇵',
      '🇯🇪', '🇯🇴', '🇰🇿', '🇰🇪', '🇰🇮', '🇽🇰', '🇰🇼', '🇰🇬', '🇱🇦', '🇱🇻',
      '🇱🇧', '🇱🇸', '🇱🇷', '🇱🇾', '🇱🇮', '🇱🇹', '🇱🇺', '🇲🇴', '🇲🇬', '🇲🇼',
      '🇲🇾', '🇲🇻', '🇲🇱', '🇲🇹', '🇲🇭', '🇲🇶', '🇲🇷', '🇲🇺', '🇾🇹', '🇲🇽',
      '🇫🇲', '🇲🇩', '🇲🇨', '🇲🇳', '🇲🇪', '🇲🇸', '🇲🇦', '🇲🇿', '🇲🇲', '🇳🇦',
      '🇳🇷', '🇳🇵', '🇳🇱', '🇳🇨', '🇳🇿', '🇳🇮', '🇳🇪', '🇳🇬', '🇳🇺', '🇳🇫',
      '🇰🇵', '🇲🇰', '🇲🇵', '🇳🇴', '🇴🇲', '🇵🇰', '🇵🇼', '🇵🇸', '🇵🇦', '🇵🇬',
      '🇵🇾', '🇵🇪', '🇵🇭', '🇵🇳', '🇵🇱', '🇵🇹', '🇵🇷', '🇶🇦', '🇷🇪', '🇷🇴',
      '🇷🇺', '🇷🇼', '🇼🇸', '🇸🇲', '🇸🇹', '🇸🇦', '🇸🇳', '🇷🇸', '🇸🇨', '🇸🇱',
      '🇸🇬', '🇸🇽', '🇸🇰', '🇸🇮', '🇸🇧', '🇸🇴', '🇿🇦', '🇬🇸', '🇰🇷', '🇸🇸',
      '🇪🇸', '🇱🇰', '🇧🇱', '🇸🇭', '🇰🇳', '🇱🇨', '🇵🇲', '🇻🇨', '🇸🇩', '🇸🇷',
      '🇸🇪', '🇨🇭', '🇸🇾', '🇹🇼', '🇹🇯', '🇹🇿', '🇹🇭', '🇹🇱', '🇹🇬', '🇹🇰',
      '🇹🇴', '🇹🇹', '🇹🇳', '🇹🇷', '🇹🇲', '🇹🇨', '🇹🇻', '🇺🇬', '🇺🇦', '🇦🇪',
      '🇬🇧', '🏴󠁧󠁢󠁥󠁮󠁧󠁿', '🏴󠁧󠁢󠁳󠁣󠁴󠁿', '🏴󠁧󠁢󠁷󠁬󠁳󠁿', '🇺🇸', '🇺🇾', '🇻🇮', '🇺🇿',
      '🇻🇺', '🇻🇦', '🇻🇪', '🇻🇳', '🇼🇫', '🇪🇭', '🇾🇪', '🇿🇲', '🇿🇼'
    ]
  }
};

// Emoji picker state
let pickerElement = null;
let currentCategory = 'smileys';
let recentEmojis = [];

/**
 * Initialize the emoji picker module
 * @param {Object} editor - Quill editor instance
 * @param {Object} options - Module options
 */
export function initEmojiPicker(editor, options = {}) {
  // Load recent emojis from options or localStorage
  recentEmojis = options.recentEmojis || [];
  try {
    const stored = localStorage.getItem('quill-emoji-recent');
    if (stored) {
      recentEmojis = JSON.parse(stored);
    }
  } catch (e) {
    console.log('Could not load recent emojis from localStorage');
  }
  
  EMOJI_CATEGORIES.recent.emojis = recentEmojis;
  
  console.log('Emoji picker initialized');
}

/**
 * Show the emoji picker
 * @param {Object} editor - Quill editor instance
 * @param {Function} onSelect - Callback when emoji is selected
 */
export function showEmojiPicker(editor, onSelect) {
  // Close existing picker
  hideEmojiPicker();
  
  // Get cursor position for placement
  const toolbar = document.querySelector('.ql-toolbar');
  const emojiBtn = document.querySelector('[data-plugin-id="emoji-picker"], .ql-emoji');
  
  let top = 50;
  let left = 10;
  
  if (emojiBtn) {
    const rect = emojiBtn.getBoundingClientRect();
    const containerRect = document.querySelector('#editor-container')?.getBoundingClientRect() || document.body.getBoundingClientRect();
    top = rect.bottom - containerRect.top + 5;
    left = Math.max(10, rect.left - containerRect.left);
  } else if (toolbar) {
    top = toolbar.offsetHeight + 5;
  }
  
  // Create picker element
  pickerElement = document.createElement('div');
  pickerElement.className = 'ql-emoji-picker';
  pickerElement.style.top = `${top}px`;
  pickerElement.style.left = `${left}px`;
  
  // Build picker HTML
  pickerElement.innerHTML = buildPickerHTML();
  
  // Add to container
  const container = document.querySelector('#editor-container') || document.body;
  container.appendChild(pickerElement);
  
  // Add event listeners
  setupPickerEvents(editor, onSelect);
  
  // Focus search
  const searchInput = pickerElement.querySelector('.ql-emoji-search');
  if (searchInput) {
    setTimeout(() => searchInput.focus(), 50);
  }
  
  // Close on outside click
  setTimeout(() => {
    document.addEventListener('click', handleOutsideClick);
  }, 100);
}

/**
 * Hide the emoji picker
 */
export function hideEmojiPicker() {
  if (pickerElement) {
    pickerElement.remove();
    pickerElement = null;
  }
  document.removeEventListener('click', handleOutsideClick);
}

/**
 * Handle clicks outside the picker
 */
function handleOutsideClick(event) {
  if (pickerElement && !pickerElement.contains(event.target)) {
    const emojiBtn = document.querySelector('[data-plugin-id="emoji-picker"], .ql-emoji');
    if (!emojiBtn || !emojiBtn.contains(event.target)) {
      hideEmojiPicker();
    }
  }
}

/**
 * Build the picker HTML
 */
function buildPickerHTML() {
  const categoryKeys = Object.keys(EMOJI_CATEGORIES);
  
  // Category buttons
  const categoryBtns = categoryKeys
    .filter(key => key === 'recent' ? EMOJI_CATEGORIES.recent.emojis.length > 0 : true)
    .map(key => {
      const cat = EMOJI_CATEGORIES[key];
      const activeClass = key === currentCategory ? 'active' : '';
      return `<button class="ql-emoji-category-btn ${activeClass}" data-category="${key}" title="${cat.name}">${cat.icon}</button>`;
    })
    .join('');
  
  // Current category emojis
  const emojis = EMOJI_CATEGORIES[currentCategory].emojis
    .map(emoji => `<button class="ql-emoji-item" data-emoji="${emoji}">${emoji}</button>`)
    .join('');
  
  // Detect platform for hint
  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0;
  const shortcut = isMac ? 'Cmd+Ctrl+Space' : 'Win+.';
  
  return `
    <input type="text" class="ql-emoji-search" placeholder="Search emojis..." />
    <div class="ql-emoji-picker-header">${categoryBtns}</div>
    <div class="ql-emoji-grid">${emojis}</div>
    <div class="ql-emoji-native-hint">Tip: Press ${shortcut} for system emoji picker</div>
  `;
}

/**
 * Set up picker event listeners
 */
function setupPickerEvents(editor, onSelect) {
  if (!pickerElement) return;
  
  // Category buttons
  pickerElement.querySelectorAll('.ql-emoji-category-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      currentCategory = btn.dataset.category;
      updatePickerCategory();
    });
  });
  
  // Emoji buttons
  pickerElement.querySelectorAll('.ql-emoji-item').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const emoji = btn.dataset.emoji;
      insertEmoji(editor, emoji, onSelect);
    });
  });
  
  // Search input
  const searchInput = pickerElement.querySelector('.ql-emoji-search');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      filterEmojis(e.target.value);
    });
    searchInput.addEventListener('click', (e) => e.stopPropagation());
    searchInput.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        hideEmojiPicker();
      }
    });
  }
}

/**
 * Update picker to show current category
 */
function updatePickerCategory() {
  if (!pickerElement) return;
  
  // Update active button
  pickerElement.querySelectorAll('.ql-emoji-category-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.category === currentCategory);
  });
  
  // Update emoji grid
  const grid = pickerElement.querySelector('.ql-emoji-grid');
  if (grid) {
    const emojis = EMOJI_CATEGORIES[currentCategory].emojis
      .map(emoji => `<button class="ql-emoji-item" data-emoji="${emoji}">${emoji}</button>`)
      .join('');
    grid.innerHTML = emojis;
    
    // Re-attach event listeners
    grid.querySelectorAll('.ql-emoji-item').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        insertEmoji(window.quillEditor, btn.dataset.emoji);
      });
    });
  }
}

/**
 * Filter emojis by search term
 */
function filterEmojis(searchTerm) {
  if (!pickerElement) return;
  
  const grid = pickerElement.querySelector('.ql-emoji-grid');
  if (!grid) return;
  
  const term = searchTerm.toLowerCase().trim();
  
  if (!term) {
    updatePickerCategory();
    return;
  }
  
  // Search all categories
  const matches = [];
  Object.values(EMOJI_CATEGORIES).forEach(cat => {
    cat.emojis.forEach(emoji => {
      // Simple search - could be enhanced with emoji names
      if (matches.indexOf(emoji) === -1) {
        matches.push(emoji);
      }
    });
  });
  
  // For now, just show first 50 emojis (search could be enhanced with emoji names)
  const emojis = matches.slice(0, 50)
    .map(emoji => `<button class="ql-emoji-item" data-emoji="${emoji}">${emoji}</button>`)
    .join('');
  
  grid.innerHTML = emojis || '<div style="padding: 20px; text-align: center; color: #888;">No emojis found</div>';
  
  // Re-attach event listeners
  grid.querySelectorAll('.ql-emoji-item').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      insertEmoji(window.quillEditor, btn.dataset.emoji);
    });
  });
}

/**
 * Insert emoji into editor
 */
function insertEmoji(editor, emoji, onSelect) {
  if (!editor || !emoji) return;
  
  // Insert at cursor
  const range = editor.getSelection(true);
  if (range) {
    editor.insertText(range.index, emoji, 'user');
    editor.setSelection(range.index + emoji.length, 0, 'user');
  } else {
    // Insert at end
    const length = editor.getLength();
    editor.insertText(length - 1, emoji, 'user');
  }
  
  // Add to recent emojis
  addToRecent(emoji);
  
  // Close picker
  hideEmojiPicker();
  
  // Callback
  if (onSelect) {
    onSelect(emoji);
  }
  
  // Focus editor
  editor.focus();
}

/**
 * Add emoji to recent list
 */
function addToRecent(emoji) {
  // Remove if already exists
  recentEmojis = recentEmojis.filter(e => e !== emoji);
  
  // Add to front
  recentEmojis.unshift(emoji);
  
  // Keep only last 24
  recentEmojis = recentEmojis.slice(0, 24);
  
  // Update category
  EMOJI_CATEGORIES.recent.emojis = recentEmojis;
  
  // Save to localStorage
  try {
    localStorage.setItem('quill-emoji-recent', JSON.stringify(recentEmojis));
  } catch (e) {
    console.log('Could not save recent emojis to localStorage');
  }
}

/**
 * Register emoji command handler
 */
export function registerEmojiCommand(editor) {
  return {
    showEmojiPicker: (data) => {
      showEmojiPicker(editor, (emoji) => {
        // Send to Flutter
        if (window.parent) {
          window.parent.postMessage(JSON.stringify({
            type: 'pluginAction',
            actionName: 'insertEmoji',
            params: { emoji: emoji }
          }), '*');
        }
      });
      return { success: true };
    }
  };
}

