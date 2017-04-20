
package com.kitchbot.module;

import android.app.Activity;
import android.app.Application;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import javax.annotation.Nullable;

import tech.cherri.tpdirect.API.TPDCard;
import tech.cherri.tpdirect.API.TPDServerType;
import tech.cherri.tpdirect.API.TPDSetup;
import tech.cherri.tpdirect.callback.TPDTokenFailureCallback;
import tech.cherri.tpdirect.callback.TPDTokenSuccessCallback;


public class TapPay extends ReactContextBaseJavaModule {
  private final ReactApplicationContext reactContext;

  public TapPay(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }
  @ReactMethod
  public void setup(int appID, String appKey, boolean dev){
    Application applicationContext = (Application) reactContext.getApplicationContext();
    if(!dev) {
      TPDSetup.initInstance(applicationContext, appID, appKey, TPDServerType.Production);
    }else{
      TPDSetup.initInstance(applicationContext, appID, appKey, TPDServerType.Sandbox);
    }
  }
  @ReactMethod
  public void createToken(String cardNumber,String dueMonth,String dueYear,String CCV,String geoLocation,final Promise promise){
    TPDCard card =new TPDCard(reactContext.getApplicationContext(),cardNumber,dueMonth,dueYear,CCV);
    card.onSuccessCallback(new TPDTokenSuccessCallback() {
      @Override
      public void onSuccess(String token, String cardLastFour) {
        WritableMap map = Arguments.createMap();
        map.putString("token",token);
        map.putString("cardLastFour",cardLastFour);

        promise.resolve(map);
      }
    }).onFailureCallback(new TPDTokenFailureCallback() {
      @Override
      public void onFailure(int status, String reportMsg) {
        promise.reject(String.valueOf(status),reportMsg);
      }
    });
    card.createToken(geoLocation);

  }
  @Override
  public String getName() {
    return "TapPay";
  }
}