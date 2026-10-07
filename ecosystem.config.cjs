// Configuración de PM2 para desarrollo.
//
// `wrangler pages dev dist` sirve el Worker compilado (dist/_worker.js)
// junto con los activos estáticos de dist/static.
module.exports = {
  apps: [
    {
      name: 'webapp',
      script: 'npx',
      args: 'wrangler pages dev dist --ip 0.0.0.0 --port 3000',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      watch: false,
      instances: 1,
      exec_mode: 'fork'
    }
  ]
}
