 // flutter_plugin.ets
 export default class PermissionPlugin implements FlutterPlugin {
   private channel?: MethodChannel;
   private context = getContext(this) as common.UIAbilityContext

   onAttachedToEngine(binding: FlutterPluginBinding): void {
     this.channel = new MethodChannel(binding.getBinaryMessenger(), "samples.flutter.dev/permission");
     let that = this;
     this.channel.setMethodCallHandler({
       onMethodCall(call: MethodCall, result: MethodResult) {
         if (call.method =="requestPermissionsFromUser" ) {
           atManager.requestPermissionsFromUser(that.context, ['ohos.permission.MICROPHONE'], (err: BusinessError, data: PermissionRequestResult) => {
               if (err) {
                 console.error(`requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
                 result.error(err.code.toString(), err.message, err.data)
               } else {
                 result.success(data.authResults[0])
               }
             });
         }
       }
     })
   }
 }