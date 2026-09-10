package org.wecoop.app

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Edge-to-edge es obligatorio con targetSdk 35 (Android 15+).
 * enableEdgeToEdge() attiva la modalità anche su API < 35 e riduce
 * gli avvisi Play Console su inset / system bars.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
