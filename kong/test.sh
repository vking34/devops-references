while true;
do
  curl http://localhost:8000/billing/status/200
  curl http://localhost:8000/billing/status/501
  curl http://localhost:8000/invoice/status/201
  curl http://localhost:8000/invoice/status/404
  curl http://localhost:8000/comments/status/200
  curl http://localhost:8000/comments/status/200
  sleep 0.01
done
