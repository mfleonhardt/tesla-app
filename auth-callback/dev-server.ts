import { createServer, IncomingMessage, ServerResponse } from 'http';
import { handler } from './src/callback';
import { APIGatewayProxyEventV2 } from 'aws-lambda';
import dotenv from 'dotenv';

dotenv.config();

const port = process.env.PORT || 3001;

const server = createServer(async (req: IncomingMessage, res: ServerResponse) => {
    if (req.url?.startsWith('/auth/callback')) {
        const url = new URL(req.url, `http://${req.headers.host}`);

        // Construct an API Gateway-like event
        const event: APIGatewayProxyEventV2 = {
            version: '2.0',
            routeKey: '$default',
            rawPath: url.pathname,
            rawQueryString: url.search.slice(1),
            headers: Object.fromEntries(
                Object.entries(req.headers).map(([key, value]) => [
                    key,
                    Array.isArray(value) ? value.join(',') : value || ''
                ])
            ),
            queryStringParameters: Object.fromEntries(url.searchParams.entries()),
            requestContext: {
                accountId: '123456789012',
                apiId: 'api-id',
                domainName: 'localhost:3000',
                domainPrefix: 'localhost',
                http: {
                    method: req.method || 'GET',
                    path: url.pathname,
                    protocol: 'HTTP/1.1',
                    sourceIp: '127.0.0.1',
                    userAgent: req.headers['user-agent'] || ''
                },
                requestId: 'test-request-id',
                routeKey: '$default',
                stage: '$default',
                time: new Date().toISOString(),
                timeEpoch: Date.now()
            },
            isBase64Encoded: false
        };

        try {
            const result = await handler(event);

            // Set headers from the Lambda response
            if (result.headers) {
                Object.entries(result.headers).forEach(([key, value]) => {
                    res.setHeader(key, value as string);
                });
            }

            // Set cookies if present
            if (result.cookies) {
                res.setHeader('Set-Cookie', result.cookies);
            }

            // Handle redirects
            if (result.statusCode === 302 && result.headers?.Location) {
                res.writeHead(302, { Location: result.headers.Location as string });
                res.end();
                return;
            }

            res.statusCode = result.statusCode || 200;
            res.end(result.body);
        } catch (error) {
            console.error('Error handling request:', error);
            res.statusCode = 500;
            res.end('Internal Server Error');
        }
    } else {
        res.statusCode = 404;
        res.end('Not Found');
    }
});

server.listen(port, () => {
    console.log(`Development server running at http://localhost:${port}`);
});