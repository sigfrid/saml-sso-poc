workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['THREAD_COUNT'] || 5)
threads threads_count, threads_count

# To be able to use rake etc
ssl_bind '0.0.0.0', 3000, {
  key: 'localhost.key',
  cert: 'localhost.crt',
  verify_mode: 'none'
}
