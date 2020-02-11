# curl-http3

curl은 아직 http3를 experimental로만 지원 하고 있는 상태이다. 그래서 QUIC를 구현한 `ngtcp2`나 [quiche](https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version)를 이용해서 컴파일해서 alt-svc http2나 http3를 사용할 수 있다.

그래서 이걸 쉽게 빌드해서 사용하기 위해 `quiche` 라이브러리로 만든 4.8Mb짜리 작은 curl docker image 를 만들어 보았다.

## 사용방법

* 쉘에 함수로 등록

```
function curl() {
docker run --rm \
    --name curl \
    leoh0/curl "$@"
}
```

* 사용

```
$ curl --http3 https://www.facebook.com/ -v -s -o /dev/null
```

## 다른방법

이 외에도 [cloudflare](https://developers.cloudflare.com/http3/intro/curl-brew)에서는 mac 용 http3 지원 curl 바이너리를 제공한다. 

```
$ brew install -s https://raw.githubusercontent.com/cloudflare/homebrew-cloudflare/master/curl.rb
```
