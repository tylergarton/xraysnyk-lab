mongod &
while ! nc -z localhost 27017; do
 sleep 1 # wait for 1 second before checking again
done

cd node_modules/goof
npm start
