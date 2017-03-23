<!--
{
  "title": "React Native Overview",
  "date": "2017-03-17T02:14:39.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

Continued from http://wp.hiogawa.net/2017/02/22/react-overview/, I'm getting into react-native implementation.

```
# Application source

[Android]
public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    protected List&lt;ReactPackage&gt; getPackages() {
      return Arrays.&lt;ReactPackage&gt;asList(
          new MainReactPackage()
      );
    }
  };
  ...
}

[Javascript]
import React, { Component } from &#039;react&#039;;
import { AppRegistry, Text } from &#039;react-native&#039;;
class HelloWorldApp extends Component {
  render() {
    return (
      &lt;Text&gt;Hello world!&lt;/Text&gt;
    );
  }
}
AppRegistry.registerComponent(&#039;HelloWorldApp&#039;, () =&gt; HelloWorldApp);


# Main path

[Android]
- new MainApplication =&gt; new ReactNativeHost

- new MainActivity =&gt;
  - createReactActivityDelegate =&gt; new ReactActivityDelegate
  - onCreate =&gt; ReactActivityDelegate::onCreate =&gt; loadApp =&gt;
    - createRootView =&gt; new ReactRootView =&gt; ... =&gt; new android.widget.FrameLayout
    - ReactNativeHost.getReactInstanceManager =&gt; createReactInstanceManager =&gt;
      - ReactInstanceManagerBuilder.addPackage (e.g. MainReactPackage)
      - ReactInstanceManagerBuilder.build =&gt; new ReactInstanceManager
    - ReactRootView.startReactApplication =&gt;
      - ReactInstanceManager.createReactContextInBackground =&gt; ... =&gt;
        - new JSCJavaScriptExecutor.Factory
        - recreateReactContextInBackground =&gt;
          - new ReactContextInitParams
          - new ReactContextInitAsyncTask (subclass of android.os.AsyncTask)
          - android.os.AsyncTask.executeOnExecutor (off thread)
    - Activity.setContentView

- (off-thread) ReactContextInitAsyncTask.doInBackground =&gt;
  - JavaScriptExecutor.Factory.create =&gt; new JSCJavaScriptExecutor
  - ReactInstanceManager.createReactContext =&gt;
    - new ReactApplicationContext =&gt; new ReactContext
    - new NativeModuleRegistryBuilder
    - new JavaScriptModuleRegistry.Builder
    - processPackage(CoreModulePackage) =&gt;
      - NativeModuleRegistryBuilder.processPackage =&gt;
        - addPackage for each CoreModulePackage.createNativeModules
      - JavaScriptModuleRegistry.Builder.add for each CoreModulePackage.createJSModules
    - processPackage (e.g. MainReactPackage) =&gt; (same as above)
    - NativeModuleRegistryBuilder.build =&gt; new NativeModuleRegistry (will passed to CatalystInstanceBuilder)
    - JavaScriptModuleRegistry.Builder.build =&gt; new JavaScriptModuleRegistry (will passed to CatalystInstanceBuilder)
    - CatalystInstanceBuilder.build =&gt; new CatalystInstanceImpl =&gt;
      - ReactQueueConfigurationImpl.create =&gt; new ReactQueueConfigurationImpl =&gt;
        - MessageQueueThreadImpl.create (for UI thread) =&gt; MessageQueueThreadImpl.create =&gt;
          - createForMainThread =&gt;
            - new MessageQueueThreadImpl =&gt; new MessageQueueThreadHandler =&gt; new android.os.Handler
        - MessageQueueThreadImpl.create (for native module thread or js thread ?) =&gt; MessageQueueThreadImpl.create =&gt;
          - startNewBackgroundThread =&gt;
            - new Thread
            - Thread.start =&gt; (on jsQueue thread)
              - MessageQueueThreadRegistry.register
              - Looper.loop()
            - new MessageQueueThreadImpl =&gt; ... =&gt; new android.os.Handler
      - initializeBridge =&gt; (cpp) CatalystInstanceImpl::initializeBridge =&gt;
        - push JavaModuleWrapper to CatalystInstanceImpl.modules as JavaNativeModule
        - new ModuleRegistry with the modules
        - Instance::initializeBridge =&gt;
          - JMessageQueueThread::runOnQueueSync =&gt;
            - (on jsQueue thread) new NativeToJsBridge =&gt;
              - JsToNativeBridge
              - JSCExecutorFactory::createJSExecutor =&gt; new JSCExecutor =&gt;
                - initOnJSVMThread =&gt;
                  - JSC_JSGlobalContextCreateInGroup
                  - several installGlobalFunction
                - installGlobalProxy(&quot;nativeModuleProxy&quot;, exceptionWrapMethod(&amp;JSCExecutor::getNativeModule)) =&gt;
                  - Object::getGlobalObject(JSGlobalContextRef).setProperty(&quot;nativeModuleProxy&quot;, ...)
              - NativeToJsBridge::registerExecutor
    - CatalystInstanceImpl.runJSBundle =&gt;
      - JSBundleLoader.loadScript (assume it&#039;s from JSBundleLoader.createAssetLoader) =&gt;
        - CatalystInstanceImpl.loadScriptFromAssets =&gt; jniLoadScriptFromAssets =&gt;
          - (cpp) CatalystInstanceImpl:: jniLoadScriptFromAssets =&gt; Instance::loadScriptFromString =&gt;
            - JInstanceCallback::incrementPendingJSCall =&gt; ?
            - NativeToJS::loadApplication =&gt;
              - runOnExecutorQueue =&gt; runOnQueue (jsQueue thread ?) =&gt;
                - (jsQueue thread ?) JSCExecutor::loadApplicationScript =&gt;
                  - evaluateScript (from JSCHelpers) =&gt; JSC_JSEvaluateScript
                  - bindBridge (bind javascript object from Libraries/BatchedBridge to cpp world)

- ReactRootView.onMeasure =&gt;
  - queue attachToReactInstanceManager to run on ui thread

- ReactContextInitAsyncTask.onPostExecute =&gt;
  - setupReactContext =&gt;
    - CatalystInstanceImpl.initialize =&gt; NativeModuleRegistry.notifyCatalystInstanceInitialized =&gt;
      - ModuleHolder.initialize =&gt; ... =&gt; NativeModule.initialize
    - attachMeasuredRootViewToInstance =&gt;
      - CatalystInstanceImpl.getNativeModule(UIManagerModule.class)
      - UIManagerModule.addMeasuredRootView =&gt;
        - UIImplementation.registerRootView =&gt;
          - createRootShadowNode
          - ShadowNodeRegistry.addRootNode
          - UIViewOperationQueue.addRootView
      - CatalystInstanceImpl.getJavaScriptModule(AppRegistry.class) =&gt;
        - JavaScriptModuleRegistry.getJavaScriptModule =&gt;
          - Proxy.newProxyInstance(new JavaScriptModuleInvocationHandler)
            - (this patches JavaScriptModule to call CatalystInstanceImpl.callFunction for normal java method call)
      - AppRegistry.runApplication =&gt;
        - CatalystInstanceImpl.callFunction =&gt; jniCallJSFunction =&gt;
          - (cpp) CatalystInstanceImpl::jniCallJSFunction =&gt; Instance::callJSFunction =&gt;
            -  JInstanceCallback::incrementPendingJSCall =&gt; ?
            - NativeToJsBridge::callFunction =&gt; runOnExecutorQueue =&gt; runOnQueue =&gt;
              - (jsQueue thread) JSCExecutor::callFunction =&gt; JSCExecutor::callFunction =&gt; callNativeModules =&gt;
                - Object::callAsFunction (object is m_callFunctionReturnFlushedQueueJS ??)
                - JsToNativeBridge::callNativeModules (as ExecutorDelegate) =&gt; runOnQueue
                  - (nativeQueue thread) callNativeMethod =&gt; NativeModule.invoke

(from javascript UIManager call)
- ?

[JavaScript]

(From android main path)
- AppRegistry.registerComponent =&gt; prepare (anonymous).run

- AppRegistry.runApplication =&gt;
  - (anonymous).run =&gt; renderApplication =&gt;
    - ReactNative.render =&gt; ReactNativeStack.render =&gt; ReactNativeMount.renderComponent =&gt; ... =&gt;
      - ReactReconciler.mountComponent =&gt; (rest is shared layer)
      - _mountImageIntoNode =&gt; UIManager.setChildren =&gt; ?

(Host component mounting)
- ReactNativeBaseComponent#mountComponent =&gt;
  - UIManager.createView =&gt; ?
  - UIManager.setChildren =&gt; ?

Q. NativeModule lifecycle (BaseJavaModule)
- (initialization) CoreModulesPackage ?
- (method call from javascript) UIManager.createView =&gt; ?

Q. Java native module vs Cxx native module (examples)
- (java) NativeModuleRegistry
- (cpp) ModuleRegistry
- CxxModuleWrapper, JavaModuleWrapper is passed around via initializeBridge

Q. how is UIManger exposed to javascript execution context ?
- (javascript) UIManager =&gt; NativeModules.UIManager =&gt; global.nativeModuleProxy.UIManager =&gt;
  - (cpp) JSCExecutor::getNativeModule =&gt; JSCNativeModules::getModule =&gt; createModule =&gt;
    - Object::getGlobalObject(context).getProperty(&quot;__fbGenNativeModule&quot;) (which is defined as genModule in Libraries/BatchedBridge/NativeModule)
    - ModuleRegistry::getConfig =&gt;
      - JavaNativeModule.getMethods (as NativeModule)
        - (this is passed from (java) JavaModuleWrapper and NativeModuleRegistry to (cpp) JavaNativeModule and ModuleRegistry)
        - JavaModuleWrapper.getMethodDescriptors =&gt;
          - (java) JavaModuleWrapper.getMethodDescriptors =&gt;
            - BaseJavaModule.getMethods =&gt; findMethods =&gt;
              - (reflecting java.lang.reflect.Method)
              - new JavaMethod (by default mType = METHOD_TYPE_ASYNC)
    - Object::callAsFunction =&gt;
      - (javascript) genModule =&gt;
        - genMethod (with one of &#039;async&#039;, &#039;promise&#039;, &#039;sync&#039;) =&gt;
          - define method as BatchedBridge.enqueueNativeCall (for async)
        - return { name: ..., module: UIManager } to (cpp)
  - return module part of it to (javascript)
- (javascript) UIManager returned

- (javascript) UIManager.createView =&gt;
  - BatchedBridge.enqueueNativeCall =&gt; global.queueImmediate (it&#039;s installed on ?)
    - (cpp) JSCExecutor::nativeimmediate something =&gt; 
      - JSCExecutor::callNativeModules =&gt; JsToNative::callNativeModules =&gt;
        - (on Native queue) m_registry-&gt;callNativeMethod

Q. how is ProxyExecutor used?
- relevance to JSCExecutor
```


# Future work

- Furthor ReactNative implementation
    - event handling
    - style calculation
    - possible race condition
    - JavascriptCore interface in detail

- Follow Android infrastructure implementation
    - Threading (AsyncTask)
    - FFI (jni, building, linking, etc ...)
    - Application lifecycle (android process management)
    - Display client/server protocol (surface flinger)