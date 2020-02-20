# react-native-shaker
Shaker is the simplest way to users give feedback into your react-native aplication.

## Getting Started
To start access https://useshaker.com, register and follow these steps.

## Installing 
```bash

yarn add react-native-shaker

cd ios && pod install && cd ..
```

## Using
```js
import Shaker from 'react-native-shaker'

export default Shaker(App, {
  projectId: '[YOUR-PROJECT-ID]'
})
```