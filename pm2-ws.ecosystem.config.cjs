module.exports = {
  apps: [
    {
      name: 'cotton-bingo-ws',
      cwd: './bingo-musical/src/ws',
      script: 'bash',
      args: ['-lc', 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'],
      env: {
        NODE_ENV: 'development',
        WS_PORT: 3030,
        LOG_DEBUG: '0',
      },
      env_production: {
        NODE_ENV: 'production',
        WS_PORT: 3030,
        LOG_DEBUG: '0',
      },
    },
    {
      name: 'cotton-bt-ws',
      cwd: './BT_Global/web/server',
      script: 'bash',
      args: ['-lc', 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'],
      env: {
        NODE_ENV: 'development',
        WS_PORT: 3031,
        LOG_DEBUG: '0',
      },
      env_production: {
        NODE_ENV: 'production',
        WS_PORT: 3031,
        LOG_DEBUG: '0',
      },
    },
    {
      name: 'cotton-quiz-ws',
      cwd: './CQ_Global/web/server',
      script: 'bash',
      args: ['-lc', 'set -a; [ -f ./.env ] && source ./.env; set +a; exec node ./server.js'],
      env: {
        NODE_ENV: 'development',
        WS_PORT: 3032,
        LOG_DEBUG: '0',
      },
      env_production: {
        NODE_ENV: 'production',
        WS_PORT: 3032,
        LOG_DEBUG: '0',
      },
    },
  ],
};
