
var {
    NativeModules
  } = require('react-native');
  var NativeTapPay = NativeModules.TapPay;
  var applePayContainer = null
  var linePayContainer = null
  var directPayContainer = null
  var samsungPayContainer = null
  class ApplePay{
    constructor(name,merchantIdentifier,countryCode,currency){
        NativeTapPay.setMerchant(name,merchantIdentifier,countryCode,currency)
    }
    async payment(items){
        NativeTapPay.clearCart("")
        for(var i=0;i<items.length;i++){
            NativeTapPay.addToCart(items[i].name,items[i].amount)
        }
        return await NativeTapPay.applePayment()
    }
    async resetCart(items){
      NativeTapPay.clearCart("")
      for(var i=0;i<items.length;i++){
          NativeTapPay.addToCart(items[i].name,items[i].amount)
      }
    }
    failedApplePayment(){
      NativeTapPay.failedApplePayment("")
    }
    successApplePayment(){
      NativeTapPay.successApplePayment("")
    }

  }
  class LinePay{
    constructor(backUrl){
      NativeTapPay.lineInitial(backUrl)
    }
    async createToken(){
      return await NativeTapPay.createLineToken()
    }
    payment(url){
      NativeTapPay.lineRedirectUrl(url)
    }
  }
  class SamsungPay{
    constructor(){
        
    }
    payment(){
    }
    
  }
  class DirectPay{
    validateDirectPayCard(cardNumber,dueMonth,dueYear, CCV,geoLocation){
        return  NativeTapPay.createToken(cardNumber,dueMonth,dueYear,CCV,geoLocation)
    }
    async createToken(cardNumber,dueMonth,dueYear, CCV,geoLocation){
        return await NativeTapPay.createToken(cardNumber,dueMonth,dueYear,CCV,geoLocation)
    }
    async payment(){

    }

  }
  class TapPay {
      constructor(appID,appKey,dev){
          this.iAppID = appID;
          this.iAppKey = appKey;
          this.iDev = dev
          NativeTapPay.setup(appID,appKey,dev);
      }
      getApplePay(name,merchantIdentifier,countryCode,currency){    
        applePayContainer = new ApplePay(name,merchantIdentifier,countryCode,currency)
        return applePayContainer
      }
      getDirectPay(){
        directPayContainer = new DirectPay()
        return directPayContainer
      }
      getLinePay(){
        linePayContainer = new LinePay()
        return linePayContainer
      }
      getSamsungPay(){
        if(!samsungPayContainer){
            samsungPayContainer = new SamsungPay()
        }
        return samsungPayContainer
      }
  }
  
  export default TapPay;
  