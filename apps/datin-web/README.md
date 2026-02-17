# Datin Web

Next.js web application for the Datin monorepo.

## Development

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Building

```bash
npm run build
npm start
```

## Testing

```bash
npm run test
```

## Linting

```bash
npm run lint
```

## Docker

```bash
docker build -t datin-web:latest .
docker run -p 3000:3000 datin-web:latest
```
