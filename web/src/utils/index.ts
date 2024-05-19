export const isEnvBrowser = (): boolean => !(window as any).invokeNative

export const fetchNui = async (name: string, data?: object) => {
    const options = {
        method: 'post',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    }

    const resourceName = (window as any).GetParentResourceName
        ? (window as any).GetParentResourceName()
        : 'nui-frame-app'

    const response = await fetch(`https://${resourceName}/${name}`, options)

    const formattedResponse = await response.json()

    return formattedResponse
}

export const useNuiEvent = (handler: (event: { action: string; data?: object }) => void) => {
    const eventListener = ({ data }: MessageEvent) => handler(data)

    window.onload = () => window.addEventListener('message', eventListener)
    window.onunload = () => window.removeEventListener('message', eventListener)
}

export const sendDebugEvent = (name: string, data?: object) => {
    if (isEnvBrowser())
        window.dispatchEvent(
            new MessageEvent('message', {
                data: {
                    action: name,
                    data: data
                }
            })
        )
}
