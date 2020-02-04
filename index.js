import Shaker from './react-native-shaker-component'

import RNShake from 'react-native-shake'

function detectShake({ shakeTimes, capture }) {
  let shakesQuantity = 0
  let shakeTimeout = null

  RNShake.addEventListener('ShakeEvent', () => {
    if (shakeTimeout) clearTimeout(shakeTimeout)
    if (shakesQuantity >= (shakeTimes - 1)) {
      capture()
      shakesQuantity = 0
    } else {
      shakesQuantity += 1
      shakeTimeout = setTimeout(() => (shakesQuantity = 0), 1000)
    }
  })
}

export default function ShakerExtended (component, params) {
  return Shaker(component, {
    ...params,
    detectShakeFn: detectShake
  })
}
