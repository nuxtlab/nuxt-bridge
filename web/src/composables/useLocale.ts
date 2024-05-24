import { fetchNui } from '../utils'

export default async (index: string, props?: object): Promise<string> => {
    const text = await fetchNui('useLocale', { index, props })

    return text
}
