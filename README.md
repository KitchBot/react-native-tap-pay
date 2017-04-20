
# react-native-tap-pay

## Getting started

`$ npm install react-native-tap-pay --save`

### Mostly automatic installation

`$ react-native link react-native-tap-pay`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tap-pay` and add `TapPay.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libTapPay.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.kitchbot.module.TapPayPackage;` to the imports at the top of the file
  - Add `new TapPayPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-tap-pay'
  	project(':react-native-tap-pay').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tap-pay/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-tap-pay')
  	```



## Usage
```javascript
import TapPay from 'react-native-tap-pay';




// TODO: What to do with the module?

var tap = new TapPay(APP_ID,'APP_KEY',true);
tap.createToken("444444444444444","12","19","798","UNKNOWN").then(function(result){
    console.log(result.cardLastFour)
    console.log(result.token)

}).catch(function(e){
    console.log(e.code)// errorCode
    console.log(e.message)// errorCode
})
```
  