# react-native-shaker
Shaker is the simplest way to users give feedback into your react-native aplication.

## Installing 
```bash

yarn add react-native-shaker

# we need this native dependencies to shaker to work
yarn add react-native-shake react-native-view-shot

cd ios && pod install && cd ..
```

## Using
```js
import Shaker from 'react-native-shaker'

export default Shaker(App, {
  projectId: '[YOUR-PROJECT-ID]'
})
```