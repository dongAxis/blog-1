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
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage()
      );
    }
  };
  ...
}

[Javascript]
import React, { Component } from 'react';
import { AppRegistry, Text } from 'react-native';
class HelloWorldApp extends Component {
  render() {
    return (
      <Text>Hello world!</Text>
    );
  }
}
AppRegistry.registerComponent('HelloWorldApp', () => HelloWorldApp);


# Main path

[Android]
- new MainApplication => new ReactNativeHost

- new MainActivity =>
  - createReactActivityDelegate => new ReactActivityDelegate
  - onCreate => ReactActivityDelegate::onCreate => loadApp =>
    - createRootView => new ReactRootView => ... => new android.widget.FrameLayout
    - ReactNativeHost.getReactInstanceManager => createReactInstanceManager =>
      - ReactInstanceManagerBuilder.addPackage (e.g. MainReactPackage)
      - ReactInstanceManagerBuilder.build => new ReactInstanceManager
    - ReactRootView.startReactApplication =>
      - ReactInstanceManager.createReactContextInBackground => ... =>
        - new JSCJavaScriptExecutor.Factory
        - recreateReactContextInBackground =>
          - new ReactContextInitParams
          - new ReactContextInitAsyncTask (subclass of android.os.AsyncTask)
          - android.os.AsyncTask.executeOnExecutor (off thread)
    - Activity.setContentView

- (off-thread) ReactContextInitAsyncTask.doInBackground =>
  - JavaScriptExecutor.Factory.create => new JSCJavaScriptExecutor
  - ReactInstanceManager.createReactContext =>
    - new ReactApplicationContext => new ReactContext
    - new NativeModuleRegistryBuilder
    - new JavaScriptModuleRegistry.Builder
    - processPackage(CoreModulePackage) =>
      - NativeModuleRegistryBuilder.processPackage =>
        - addPackage for each CoreModulePackage.createNativeModules
      - JavaScriptModuleRegistry.Builder.add for each CoreModulePackage.createJSModules
    - processPackage (e.g. MainReactPackage) => (same as above)
    - NativeModuleRegistryBuilder.build => new NativeModuleRegistry (will passed to CatalystInstanceBuilder)
    - JavaScriptModuleRegistry.Builder.build => new JavaScriptModuleRegistry (will passed to CatalystInstanceBuilder)
    - CatalystInstanceBuilder.build => new CatalystInstanceImpl =>
      - ReactQueueConfigurationImpl.create => new ReactQueueConfigurationImpl =>
        - MessageQueueThreadImpl.create (for UI thread) => MessageQueueThreadImpl.create =>
          - createForMainThread =>
            - new MessageQueueThreadImpl => new MessageQueueThreadHandler => new android.os.Handler
        - MessageQueueThreadImpl.create (for native module thread or js thread ?) => MessageQueueThreadImpl.create =>
          - startNewBackgroundThread =>
            - new Thread
            - Thread.start => (on jsQueue thread)
              - MessageQueueThreadRegistry.register
              - Looper.loop()
            - new MessageQueueThreadImpl => ... => new android.os.Handler
      - initializeBridge => (cpp) CatalystInstanceImpl::initializeBridge =>
        - push JavaModuleWrapper to CatalystInstanceImpl.modules as JavaNativeModule
        - new ModuleRegistry with the modules
        - Instance::initializeBridge =>
          - JMessageQueueThread::runOnQueueSync =>
            - (on jsQueue thread) new NativeToJsBridge =>
              - JsToNativeBridge
              - JSCExecutorFactory::createJSExecutor => new JSCExecutor =>
                - initOnJSVMThread =>
                  - JSC_JSGlobalContextCreateInGroup
                  - several installGlobalFunction
                - installGlobalProxy("nativeModuleProxy", exceptionWrapMethod(&amp;JSCExecutor::getNativeModule)) =>
                  - Object::getGlobalObject(JSGlobalContextRef).setProperty("nativeModuleProxy", ...)
              - NativeToJsBridge::registerExecutor
    - CatalystInstanceImpl.runJSBundle =>
      - JSBundleLoader.loadScript (assume it's from JSBundleLoader.createAssetLoader) =>
        - CatalystInstanceImpl.loadScriptFromAssets => jniLoadScriptFromAssets =>
          - (cpp) CatalystInstanceImpl:: jniLoadScriptFromAssets => Instance::loadScriptFromString =>
            - JInstanceCallback::incrementPendingJSCall => ?
            - NativeToJS::loadApplication =>
              - runOnExecutorQueue => runOnQueue (jsQueue thread ?) =>
                - (jsQueue thread ?) JSCExecutor::loadApplicationScript =>
                  - evaluateScript (from JSCHelpers) => JSC_JSEvaluateScript
                  - bindBridge (bind javascript object from Libraries/BatchedBridge to cpp world)

- ReactRootView.onMeasure =>
  - queue attachToReactInstanceManager to run on ui thread

- ReactContextInitAsyncTask.onPostExecute =>
  - setupReactContext =>
    - CatalystInstanceImpl.initialize => NativeModuleRegistry.notifyCatalystInstanceInitialized =>
      - ModuleHolder.initialize => ... => NativeModule.initialize
    - attachMeasuredRootViewToInstance =>
      - CatalystInstanceImpl.getNativeModule(UIManagerModule.class)
      - UIManagerModule.addMeasuredRootView =>
        - UIImplementation.registerRootView =>
          - createRootShadowNode
          - ShadowNodeRegistry.addRootNode
          - UIViewOperationQueue.addRootView
      - CatalystInstanceImpl.getJavaScriptModule(AppRegistry.class) =>
        - JavaScriptModuleRegistry.getJavaScriptModule =>
          - Proxy.newProxyInstance(new JavaScriptModuleInvocationHandler)
            - (this patches JavaScriptModule to call CatalystInstanceImpl.callFunction for normal java method call)
      - AppRegistry.runApplication =>
        - CatalystInstanceImpl.callFunction => jniCallJSFunction =>
          - (cpp) CatalystInstanceImpl::jniCallJSFunction => Instance::callJSFunction =>
            -  JInstanceCallback::incrementPendingJSCall => ?
            - NativeToJsBridge::callFunction => runOnExecutorQueue => runOnQueue =>
              - (jsQueue thread) JSCExecutor::callFunction => JSCExecutor::callFunction => callNativeModules =>
                - Object::callAsFunction (object is m_callFunctionReturnFlushedQueueJS ??)
                - JsToNativeBridge::callNativeModules (as ExecutorDelegate) => runOnQueue
                  - (nativeQueue thread) callNativeMethod => NativeModule.invoke

(from javascript UIManager call)
- ?

[JavaScript]

(From android main path)
- AppRegistry.registerComponent => prepare (anonymous).run

- AppRegistry.runApplication =>
  - (anonymous).run => renderApplication =>
    - ReactNative.render => ReactNativeStack.render => ReactNativeMount.renderComponent => ... =>
      - ReactReconciler.mountComponent => (rest is shared layer)
      - _mountImageIntoNode => UIManager.setChildren => ?

(Host component mounting)
- ReactNativeBaseComponent#mountComponent =>
  - UIManager.createView => ?
  - UIManager.setChildren => ?

Q. NativeModule lifecycle (BaseJavaModule)
- (initialization) CoreModulesPackage ?
- (method call from javascript) UIManager.createView => ?

Q. Java native module vs Cxx native module (examples)
- (java) NativeModuleRegistry
- (cpp) ModuleRegistry
- CxxModuleWrapper, JavaModuleWrapper is passed around via initializeBridge

Q. how is UIManger exposed to javascript execution context ?
- (javascript) UIManager => NativeModules.UIManager => global.nativeModuleProxy.UIManager =>
  - (cpp) JSCExecutor::getNativeModule => JSCNativeModules::getModule => createModule =>
    - Object::getGlobalObject(context).getProperty("__fbGenNativeModule") (which is defined as genModule in Libraries/BatchedBridge/NativeModule)
    - ModuleRegistry::getConfig =>
      - JavaNativeModule.getMethods (as NativeModule)
        - (this is passed from (java) JavaModuleWrapper and NativeModuleRegistry to (cpp) JavaNativeModule and ModuleRegistry)
        - JavaModuleWrapper.getMethodDescriptors =>
          - (java) JavaModuleWrapper.getMethodDescriptors =>
            - BaseJavaModule.getMethods => findMethods =>
              - (reflecting java.lang.reflect.Method)
              - new JavaMethod (by default mType = METHOD_TYPE_ASYNC)
    - Object::callAsFunction =>
      - (javascript) genModule =>
        - genMethod (with one of 'async', 'promise', 'sync') =>
          - define method as BatchedBridge.enqueueNativeCall (for async)
        - return { name: ..., module: UIManager } to (cpp)
  - return module part of it to (javascript)
- (javascript) UIManager returned

- (javascript) UIManager.createView =>
  - BatchedBridge.enqueueNativeCall => global.queueImmediate (it's installed on ?)
    - (cpp) JSCExecutor::nativeimmediate something => 
      - JSCExecutor::callNativeModules => JsToNative::callNativeModules =>
        - (on Native queue) m_registry->callNativeMethod

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