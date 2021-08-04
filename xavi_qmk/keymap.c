#include QMK_KEYBOARD_H

#ifdef RGBLIGHT_ENABLE
//Following line allows macro to read current RGB settings
extern rgblight_config_t rgblight_config;
#endif

extern uint8_t is_master;


// used to create macros:  https://docs.qmk.fm/#/feature_macros
enum custom_keycodes {
    MACRO_JR = SAFE_RANGE,
    MACRO_FULLS,
    MACRO2
};

// Shortcuts
#define COPY      LCTL(KC_INS)
#define CUT       LSFT(KC_DEL)
#define PASTE     RSFT(KC_INS)
#define VOL_UP    SGUI(KC_RBRC)
#define VOL_DOWN  SGUI(KC_SLSH)


// Each layer gets a name for readability, which is then used in the keymap matrix below.
// The underscores don't mean anything - you can have a layer called STUFF or any other name.
// Layer names don't all need to be of the same length, obviously, and you can also skip them
// entirely and just use numbers.
//
#define _QWERTY   0
#define _NUMS     1
#define _ARROWS   2
#define _SYMBOLS  3
#define _SUPWKS   4
#define _CONFBSP  5
#define _FXX      6 
#define _MACRO    7

// TODO
//  check if this combos are "easy"
//   - Ctrl + Shift + R   ->  Eclipse : open resource
//   - Ctrl + Shift + C   ->  Eclipse : toggle comment code
//   - Ctrl + Shift + 7   ->  Eclipse : toggle comment code
//   - Super + Shift +   ->  volume up
//   - Super + Shift -   ->  volume down
//
//

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

	// layer 0 : BASE - DEFAULT
    [_QWERTY] = LAYOUT_split_3x6_3( \
        LT(1,KC_ESC),    KC_Q,          KC_W,   KC_E,   KC_R,        KC_T,          KC_Y,   KC_U,   KC_I,    KC_O,           KC_P,            KC_BSPC, \
        LT(2,KC_TAB),    KC_A,          KC_S,   KC_D,   LT(6,KC_F),  KC_G,          KC_H,   KC_J,   KC_K,    KC_L,           KC_SCLN,         LT(3,KC_QUOT), \
        LSFT_T(KC_MINS), LCTL_T(KC_Z),  KC_X,   KC_C,   KC_V,        KC_B,          KC_N,   KC_M,   KC_COMM, RALT_T(KC_DOT), RCTL_T(KC_SLSH), RSFT_T(KC_LBRC), \
                                    LM(4,MOD_LGUI),  LALT_T(KC_MINS),  KC_SPC,   KC_ENT,  LM(5,MOD_LGUI),  LT(7,KC_DEL)  \
    ),

	// layer 1
    [_NUMS] = LAYOUT_split_3x6_3( \
        XXXXXXX, XXXXXXX, XXXXXXX, S(KC_RBRC), S(KC_0), KC_RBRC,                KC_1,  KC_2,  KC_3,  KC_RBRC,  S(KC_RBRC),  _______,\
        XXXXXXX, KC_LSFT, KC_LCTL, XXXXXXX,    XXXXXXX, KC_SLSH,                KC_4,  KC_5,  KC_6,  KC_SLSH,  S(KC_7),     XXXXXXX,\
        _______, XXXXXXX, KC_LALT, XXXXXXX,    S(KC_7), S(KC_RBRC),             KC_7,  KC_8,  KC_9,  KC_0,     KC_DOT,      _______,\
                                            KC_LGUI, XXXXXXX, _______,      _______, KC_RGUI, XXXXXXX \
    ),

	// layer 2
    [_ARROWS] = LAYOUT_split_3x6_3( \
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, CUT,              KC_HOME,  KC_PGUP,  XXXXXXX,  S(KC_INS), XXXXXXX, CUT, \
        XXXXXXX, KC_LSFT, KC_LCTL, XXXXXXX, XXXXXXX, COPY,             KC_LEFT,  KC_DOWN,  KC_UP,    KC_RIGHT,  XXXXXXX, COPY, \
        XXXXXXX, XXXXXXX, KC_LALT, XXXXXXX, XXXXXXX, PASTE,            KC_END,   KC_PGDN,  XXXXXXX,  XXXXXXX,   XXXXXXX, PASTE, \
                                      KC_LGUI, _______, XXXXXXX,    KC_RCTL,  KC_RGUI,  XXXXXXX \
    ),

	// layer 3
    [_SYMBOLS] = LAYOUT_split_3x6_3( \
        // |         // #        // $           // @          // (           // )                 // ?        // ¿        // "      // '        // ç
        ALGR(KC_1), ALGR(KC_3), S(KC_4),       ALGR(KC_2),   S(KC_8),       S(KC_9),             S(KC_MINS), S(KC_EQL),  S(KC_2),  KC_MINS,    KC_NUHS,   _______, \
        // º         // &        // ~           // /          // {           // }                 // !        // ¡        // =      // %        // PrScr  
        KC_GRV,     S(KC_6),    ALGR(KC_SCLN), S(KC_7),      ALGR(KC_QUOT), ALGR(KC_NUHS),       KC_EXLM,    KC_EQL,     S(KC_0),  KC_PERC,    KC_PSCR,   XXXXXXX, \
        // ª         // ^        // DEL         // \          // [           // ]                 // <        // >        // ·      // " (like in ä)
        S(KC_GRV),  S(KC_LBRC), KC_DEL,        ALGR(KC_GRV), ALGR(KC_LBRC), ALGR(KC_RBRC),       KC_NUBS,    S(KC_NUBS), S(KC_3),  S(KC_QUOT), XXXXXXX,   XXXXXXX, \
                                                              _______,  _______,  _______,        _______, _______, _______ \
    ),

	// layer 4
    [_SUPWKS] = LAYOUT_split_3x6_3( \
        XXXXXXX,  XXXXXXX, KC_W,    KC_E,  XXXXXXX,  KC_T,                  KC_1,  KC_2,  KC_3,  XXXXXXX,  KC_P,    _______,\
        KC_TAB,   KC_A,    KC_S,    KC_D,  KC_F,     XXXXXXX,               KC_4,  KC_5,  KC_6,  XXXXXXX,  KC_SCLN, XXXXXXX, \
        _______,  KC_RCTL, XXXXXXX, KC_C,  KC_V,     XXXXXXX,               KC_7,  KC_8,  KC_9,  KC_0,     KC_MINS, KC_EQL,\
                                        XXXXXXX, XXXXXXX, XXXXXXX,     KC_ENT, XXXXXXX, XXXXXXX \
    ),

	// layer 5
    [_CONFBSP] = LAYOUT_split_3x6_3( \
        KC_ESC,  XXXXXXX, KC_W,     KC_E,    XXXXXXX,  KC_T,              KC_Y,      XXXXXXX,   XXXXXXX,   XXXXXXX,   KC_P,     _______, \
        KC_TAB,  KC_A,    KC_S,     KC_D,    KC_F,     XXXXXXX,           KC_H,      KC_J,      KC_K,      KC_L,      KC_SCLN,  KC_RBRC, \
        _______, KC_RCTL, XXXXXXX,  KC_C,    KC_V,     XXXXXXX,           XXXXXXX,   KC_M,      _______,   _______,   _______,  KC_SLSH, \
                                     XXXXXXX,   XXXXXXX,  XXXXXXX,      KC_ENT,  XXXXXXX,  XXXXXXX \
    ),

	// layer 6
    [_FXX] = LAYOUT_split_3x6_3( \
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                   KC_F1,  KC_F2,  KC_F3,  XXXXXXX,  XXXXXXX,  XXXXXXX,\
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                   KC_F4,  KC_F5,  KC_F6,  XXXXXXX,  XXXXXXX,  XXXXXXX,\
        _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                   KC_F7,  KC_F8,  KC_F9,  KC_F10,   KC_F11,   KC_F12, \
                                      XXXXXXX,   XXXXXXX,  XXXXXXX,      XXXXXXX,   XXXXXXX,  XXXXXXX \
    ),

	// macro 7
    [_MACRO] = LAYOUT_split_3x6_3( \
        RESET,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,      XXXXXXX,                 XXXXXXX,  XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,\
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, MACRO_FULLS,  MACRO2,                  XXXXXXX,  MACRO_JR,  XXXXXXX, XXXXXXX, XXXXXXX, VOL_UP,\
        XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,      XXXXXXX,                 XXXXXXX,  XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, VOL_DOWN,\
                                           XXXXXXX,   XXXXXXX,  XXXXXXX,      XXXXXXX,  XXXXXXX,  XXXXXXX \
    )
};

int RGB_current_mode;

void persistent_default_layer_set(uint16_t default_layer) {
    eeconfig_update_default_layer(default_layer);
    default_layer_set(default_layer);
}

/*
// Setting ADJUST layer RGB back to default
void update_tri_layer_RGB(uint8_t layer1, uint8_t layer2, uint8_t layer3) {
    if (IS_LAYER_ON(layer1) && IS_LAYER_ON(layer2)) {
        layer_on(layer3);
    } else {
        layer_off(layer3);
    }
}*/

void matrix_init_user(void) {
    #ifdef RGBLIGHT_ENABLE
            RGB_current_mode = rgblight_config.mode;
    #endif
    //SSD1306 OLED init, make sure to add #define SSD1306OLED in config.h
    #ifdef SSD1306OLED
        iota_gfx_init(!has_usb());   // turns on the display
    #endif
}


bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
		case MACRO_JR:
		    if (record->event.pressed) {
				SEND_STRING("jrdomain"SS_TAP(X_ENT)"cd arc"SS_TAP(X_ENT)"cd logs"SS_TAP(X_ENT)"cd SdrServer"SS_TAP(X_ENT)"ll"SS_TAP(X_ENT));
			}
			return false;

		case MACRO_FULLS:
		    if (record->event.pressed) {
				//   (   és   *  (no funciona)
				//   )   és   =
				//   ?   és   _
				SEND_STRING("select "SS_RSFT("]")" from gr?fulls f"SS_TAP(X_ENT)"inner join gr?fulls?recollida r on f.tipus?full ) r.tipus?full and f.num?full ) r.num?full"SS_TAP(X_ENT));
			}
			return false;

		case MACRO2:
		    if (record->event.pressed) {
				SEND_STRING("admin123");	
			}
			return false;
	}
    return true;
}


//
// because we put in config.h:   #define TAPPING_TERM_PER_KEY
// 
// we defined ::  TAPPING_TERM 200
//
uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case LT(6, KC_F):
            return TAPPING_TERM + 150;	
        case LCTL_T(KC_Z):
			return TAPPING_TERM - 25;
        case RCTL_T(KC_SLSH):
			return TAPPING_TERM - 25;
		case RSFT_T(KC_LBRC):
			return TAPPING_TERM - 25;
		case RALT_T(KC_DOT):
			return TAPPING_TERM - 25;
        default:
            return TAPPING_TERM;
    }
}
