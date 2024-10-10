module.exports = {
  apps: [{
    name: "crmDeliciu",
    script: 'index.js',
    watch: true,
    ignore_watch: ["logs", "node_modules"],
    autorestart: true,
    instances: -2,
    exec_mode: "cluster",
  }, {
    script: './service-worker/',
    watch: ['./service-worker']
  }],

  deploy : {
    production : {
      user : 'SSH_USERNAME',
      host : 'SSH_HOSTMACHINE',
      ref  : 'origin/master',
      repo : 'GIT_REPOSITORY',
      path : 'DESTINATION_PATH',
      'pre-deploy-local': '',
      'post-deploy' : 'npm install && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
