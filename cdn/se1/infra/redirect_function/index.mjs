import { URLSearchParams } from 'url';

export async function handler(event) {
    const request = event.Records[0].cf.request;
    const uri = request.uri;

    if (uri !== '/' && uri !== '/index.html' && !uri.startsWith('/images')) {
        return {
            status: '302',
            statusDescription: 'Found',
            headers: {
                location: [{
                    key: 'Location',
                    value: '/',
                }],
            },
        };
    }

    return request;
}