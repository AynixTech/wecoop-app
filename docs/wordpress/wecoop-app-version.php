<?php
/**
 * Plugin Name: WECOOP App Version
 * Description: Espone la configurazione delle versioni dell'app WECOOP e ne
 *              consente la gestione dalle impostazioni. L'app mobile la usa per
 *              forzare o suggerire l'aggiornamento.
 * Version:     1.0.0
 * Author:      WECOOP / Aynix
 *
 * ============================================================================
 *  INSTALLAZIONE
 *  ------------
 *  Opzione A (consigliata) - mu-plugin (sempre attivo, non disattivabile):
 *    Carica questo file in:  wp-content/mu-plugins/wecoop-app-version.php
 *    (se la cartella mu-plugins non esiste, creala)
 *
 *  Opzione B - plugin normale:
 *    Metti il file in una cartella:  wp-content/plugins/wecoop-app-version/wecoop-app-version.php
 *    poi attivalo da Plugin nel backend WordPress.
 *
 *  GESTIONE VERSIONI
 *  -----------------
 *  Dopo l'installazione trovi un menu:  Impostazioni > App WECOOP
 *  dove puoi cambiare min_build / latest_build / store_url senza toccare il codice.
 *
 *  ENDPOINT PUBBLICO
 *  -----------------
 *    GET https://www.wecoop.org/wp-json/wecoop/v1/app-version
 * ============================================================================
 */

if (!defined('ABSPATH')) {
    exit; // accesso diretto negato
}

/* -------------------------------------------------------------------------
 * VALORI DI DEFAULT
 * Il "build" è il numero dopo il "+" in pubspec.yaml (version: 1.4.0+17 -> 17).
 * - min_build:    sotto questo -> aggiornamento OBBLIGATORIO (blocco totale)
 * - latest_build: ultima versione pubblicata -> aggiornamento OPZIONALE
 * ---------------------------------------------------------------------- */
function wecoop_app_version_defaults() {
    return array(
        'android_min_build'    => 17,
        'android_latest_build' => 17,
        'android_store_url'    => 'https://play.google.com/store/apps/details?id=org.wecoop.app',
        'ios_min_build'        => 17,
        'ios_latest_build'     => 17,
        // TODO: sostituire idXXXXXXXXXX con l'Apple ID reale (App Store Connect)
        'ios_store_url'        => 'https://apps.apple.com/app/idXXXXXXXXXX',
        'message'              => '', // opzionale, testo custom mostrato nell'app
    );
}

function wecoop_app_version_get_config() {
    $defaults = wecoop_app_version_defaults();
    $saved    = get_option('wecoop_app_version', array());
    $c        = wp_parse_args($saved, $defaults);

    return array(
        'android' => array(
            'min_build'    => (int) $c['android_min_build'],
            'latest_build' => (int) $c['android_latest_build'],
            'store_url'    => esc_url_raw($c['android_store_url']),
            'message'      => $c['message'] !== '' ? $c['message'] : null,
        ),
        'ios' => array(
            'min_build'    => (int) $c['ios_min_build'],
            'latest_build' => (int) $c['ios_latest_build'],
            'store_url'    => esc_url_raw($c['ios_store_url']),
            'message'      => $c['message'] !== '' ? $c['message'] : null,
        ),
    );
}

/* -------------------------------------------------------------------------
 * ENDPOINT REST: /wp-json/wecoop/v1/app-version
 * ---------------------------------------------------------------------- */
add_action('rest_api_init', function () {
    register_rest_route('wecoop/v1', '/app-version', array(
        'methods'             => 'GET',
        'permission_callback' => '__return_true', // pubblico
        'callback'            => function () {
            $response = new WP_REST_Response(wecoop_app_version_get_config(), 200);
            // Cache breve lato CDN/browser: 5 minuti
            $response->header('Cache-Control', 'public, max-age=300');
            return $response;
        },
    ));
});

/* -------------------------------------------------------------------------
 * PAGINA IMPOSTAZIONI: Impostazioni > App WECOOP
 * ---------------------------------------------------------------------- */
add_action('admin_menu', function () {
    add_options_page(
        'App WECOOP',
        'App WECOOP',
        'manage_options',
        'wecoop-app-version',
        'wecoop_app_version_settings_page'
    );
});

add_action('admin_init', function () {
    register_setting('wecoop_app_version_group', 'wecoop_app_version', array(
        'type'              => 'array',
        'sanitize_callback' => 'wecoop_app_version_sanitize',
        'default'           => wecoop_app_version_defaults(),
    ));
});

function wecoop_app_version_sanitize($input) {
    $defaults = wecoop_app_version_defaults();
    $out = array();
    $out['android_min_build']    = isset($input['android_min_build']) ? (int) $input['android_min_build'] : $defaults['android_min_build'];
    $out['android_latest_build'] = isset($input['android_latest_build']) ? (int) $input['android_latest_build'] : $defaults['android_latest_build'];
    $out['android_store_url']    = isset($input['android_store_url']) ? esc_url_raw(trim($input['android_store_url'])) : $defaults['android_store_url'];
    $out['ios_min_build']        = isset($input['ios_min_build']) ? (int) $input['ios_min_build'] : $defaults['ios_min_build'];
    $out['ios_latest_build']     = isset($input['ios_latest_build']) ? (int) $input['ios_latest_build'] : $defaults['ios_latest_build'];
    $out['ios_store_url']        = isset($input['ios_store_url']) ? esc_url_raw(trim($input['ios_store_url'])) : $defaults['ios_store_url'];
    $out['message']              = isset($input['message']) ? sanitize_textarea_field($input['message']) : '';
    return $out;
}

function wecoop_app_version_settings_page() {
    $c = wp_parse_args(get_option('wecoop_app_version', array()), wecoop_app_version_defaults());
    ?>
    <div class="wrap">
        <h1>Configurazione versioni App WECOOP</h1>
        <p>
            Il <strong>build</strong> è il numero dopo il <code>+</code> in <code>pubspec.yaml</code>
            (es. <code>version: 1.4.0+17</code> &rarr; build <strong>17</strong>).<br>
            <strong>min_build</strong>: sotto questo valore l'app forza l'aggiornamento (blocco totale).<br>
            <strong>latest_build</strong>: ultima versione pubblicata (aggiornamento opzionale).
        </p>
        <p>Endpoint pubblico: <code><?php echo esc_url(rest_url('wecoop/v1/app-version')); ?></code></p>

        <form method="post" action="options.php">
            <?php settings_fields('wecoop_app_version_group'); ?>

            <h2>Android</h2>
            <table class="form-table">
                <tr>
                    <th><label>Build minimo (obbligatorio)</label></th>
                    <td><input type="number" name="wecoop_app_version[android_min_build]" value="<?php echo esc_attr($c['android_min_build']); ?>"></td>
                </tr>
                <tr>
                    <th><label>Ultimo build (disponibile)</label></th>
                    <td><input type="number" name="wecoop_app_version[android_latest_build]" value="<?php echo esc_attr($c['android_latest_build']); ?>"></td>
                </tr>
                <tr>
                    <th><label>URL Play Store</label></th>
                    <td><input type="url" class="regular-text" name="wecoop_app_version[android_store_url]" value="<?php echo esc_attr($c['android_store_url']); ?>"></td>
                </tr>
            </table>

            <h2>iOS</h2>
            <table class="form-table">
                <tr>
                    <th><label>Build minimo (obbligatorio)</label></th>
                    <td><input type="number" name="wecoop_app_version[ios_min_build]" value="<?php echo esc_attr($c['ios_min_build']); ?>"></td>
                </tr>
                <tr>
                    <th><label>Ultimo build (disponibile)</label></th>
                    <td><input type="number" name="wecoop_app_version[ios_latest_build]" value="<?php echo esc_attr($c['ios_latest_build']); ?>"></td>
                </tr>
                <tr>
                    <th><label>URL App Store</label></th>
                    <td><input type="url" class="regular-text" name="wecoop_app_version[ios_store_url]" value="<?php echo esc_attr($c['ios_store_url']); ?>"></td>
                </tr>
            </table>

            <h2>Messaggio (opzionale)</h2>
            <table class="form-table">
                <tr>
                    <th><label>Testo personalizzato</label></th>
                    <td>
                        <textarea name="wecoop_app_version[message]" rows="3" class="large-text"><?php echo esc_textarea($c['message']); ?></textarea>
                        <p class="description">Se compilato, sovrascrive i testi tradotti dell'app nel dialogo di aggiornamento.</p>
                    </td>
                </tr>
            </table>

            <?php submit_button(); ?>
        </form>
    </div>
    <?php
}
