package com.partner.app.flutter_partner_app

import android.os.Handler
import com.vnpt.smartca.*
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.app.AlertDialog

class MainActivity : FlutterFragmentActivity() {
    var VNPTSmartCA = VNPTSmartCASDK()
    lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
      GeneratedPluginRegistrant.registerWith(flutterEngine)
      try {
        var customParams = CustomParams(
          borderRadiusBtn = 999.0,
          colorSecondBtn = "#DEF7EB",
          colorPrimaryBtn = "#33CC80",
          featuresLink = "",
          logoCustom = "",
          backgroundLogin = ""
        );

        fun createConfig(isProd: Boolean): ConfigSDK {
          return if (isProd) {
            ConfigSDK(
              env = SmartCAEnvironment.PROD_ENV,
              clientId = "",
              clientSecret = "",
              lang = SmartCALanguage.VI,
              isFlutter = true,
              customParams = customParams,
            )
          } else {
            ConfigSDK(
              env = SmartCAEnvironment.DEMO_ENV,
              clientId = "",
              clientSecret = "",
              lang = SmartCALanguage.VI,
              isFlutter = true,
              customParams = customParams,
            )
          }
        }

        VNPTSmartCA.initSDK(this, createConfig(false))

        methodChannel =
          MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.vnpt.flutter/partner")
        methodChannel.setMethodCallHandler { call, result ->
          when (call.method) {
            "switchEnvironment" -> {
              val env = call.arguments as? String
              val isProd = env?.uppercase() == "PROD"
              VNPTSmartCA.initSDK(this, createConfig(isProd))
              result.success("OK")
            }
            // "createAccount" -> createAccount();
            "getAuthentication" -> (call.arguments as? String)?.let { getAuthentication(it) };
            "getMainInfo" -> getMainInfo()
            "getWaitingTransaction" -> (call.arguments as? String)?.let { getWaitingTransaction(it) };
            "signOut" -> signOut()
            else -> result.notImplemented()
            //     try {
            //         VNPTSmartCA.createAccount { result ->
            //             methodChannel.invokeMethod("createAccountResult", getMap(result))
            //         }
            //     } catch (ex: Exception) {
            //         throw ex;
          }
        }
      } catch (ex: Exception){
        throw ex;
      }
    }

    private fun getAuthentication(customerId: String) {
        try {
          
            VNPTSmartCA.getAuthentication(customerId) { result ->
                    methodChannel.invokeMethod("getAuthenticationResult", getMap(result))
            }
        } catch (ex: Exception) {
            throw ex;
        }
    }

    private fun getMainInfo() {
        try {
            VNPTSmartCA.getMainInfo { result ->
                methodChannel.invokeMethod("getMainInfoResult", getMap(result))
            }
        } catch (ex: Exception) {
            throw ex;
        }
    }

    private fun getWaitingTransaction(transId: String) {
        try {
            VNPTSmartCA.getWaitingTransaction(transId) { result ->
                methodChannel.invokeMethod("getWaitingTransactionResult", getMap(result))
            }
        } catch (ex: Exception) {
            throw ex;
        }
    }

    private fun signOut() {
        try {
            VNPTSmartCA.signOut { result ->
                methodChannel.invokeMethod("signOutResult", getMap(result))
            }
        } catch (ex: Exception) {
            throw ex;
        }
    }

    fun getMap(result: SmartCAResult) : HashMap<String, Any> {
        var hashMap = HashMap<String, Any> ()
        hashMap.put("status", result.status)
        result.statusDesc?.let { hashMap.put("statusDesc", it) }
        result.data?.let { hashMap.put("data", it) }
        return hashMap;
    }
}
