
var {
  NativeModules
} = require('react-native');

function TapPay(appID,appKey,dev){
    var instance = this;
    var iAppID = appID;
    var iAppKey = appKey;
    var iDev = dev

    var NativeTapPay = NativeModules.TapPay;
    NativeTapPay.setup(appID,appKey,dev);
    TapPay.prototype.createToken = async function(cardNumber,dueMonth,dueYear, CCV,geoLocation){
        return await NativeTapPay.createToken(cardNumber,dueMonth,dueYear,CCV,geoLocation)
    }
    TapPay = function(appID,appKey,dev){
        if(iAppID!==appID || iDev!==dev || iAppKey!=appKey){
            iAppID = appID
            iDev = dev
            iAppKey = appKey

            NativeTapPay.setup(appID,appKey,dev);
        }
        return instance
    }


}


export default TapPay;
