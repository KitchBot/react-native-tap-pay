
package com.kitchbot.module;
import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.app.Application;
import android.support.v4.content.*;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import android.support.v4.app.ActivityCompat;

import javax.annotation.Nullable;

import tech.cherri.tpdirect.api.TPDCard;
import tech.cherri.tpdirect.api.TPDCardInfo;
import tech.cherri.tpdirect.api.TPDMerchant;
import tech.cherri.tpdirect.api.TPDSamsungPay;
import tech.cherri.tpdirect.api.TPDServerType;
import tech.cherri.tpdirect.api.TPDSetup;
import tech.cherri.tpdirect.callback.TPDSamsungPayStatusListener;
import tech.cherri.tpdirect.callback.TPDTokenFailureCallback;
import tech.cherri.tpdirect.callback.TPDTokenSuccessCallback;


public class TapPay extends ReactContextBaseJavaModule implements TPDSamsungPayStatusListener, TPDTokenSuccessCallback, TPDTokenFailureCallback {
  private TPDSamsungPay tpdSamsungPay;
  private boolean isReadyPay = false;
  private static final int REQUEST_READ_PHONE_STATE = 101;
  private TPDCard.CardType[] allowedNetworks = new TPDCard.CardType[]{TPDCard.CardType.Visa
            , TPDCard.CardType.MasterCard};

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

    TPDCard card =new TPDCard( reactContext.getApplicationContext(),new StringBuffer(cardNumber),new StringBuffer(dueMonth),new StringBuffer(dueYear),new StringBuffer(CCV));
    card.onSuccessCallback(new TPDTokenSuccessCallback() {
      @Override
      public void onSuccess(String token, TPDCardInfo tpdCardInfo) {
        String cardLastFour = tpdCardInfo.getLastFour();
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
    public void onReadyToPayChecked(boolean isReadyToPay, String msg) {
        if (isReadyToPay) {
            isReadyPay = true;
        } else {
            isReadyPay = false;
        }
    }

    @ReactMethod
  public void setMerchant(String name, String merchant_id,String service_id,String countryCode,String currency) {
        TPDMerchant tpdMerchant = new TPDMerchant();
        tpdMerchant.setMerchantName(name);
        tpdMerchant.setSupportedNetworks(allowedNetworks);
        tpdMerchant.setSamsungMerchantId(merchant_id);
        tpdMerchant.setCurrencyCode(currency);

        tpdSamsungPay = new TPDSamsungPay(reactContext.getApplicationContext() , service_id, tpdMerchant);
        tpdSamsungPay.isSamsungPayAvailable(this);
  }

  @Override
  public void onSuccess(String prime, TPDCardInfo cardInfo) {

  }

  @Override
  public void onFailure(int status, String reportMsg) {
      
  }

  
  @Override
  public String getName() {
    return "TapPay";
  }
}