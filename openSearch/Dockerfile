# Compose의 args에서 OpenSearch 버전을 인자로 받아 전달하기 위해 인자 선언.
ARG OPENSEARCH_VERSION=2.19.3

# 공식 이미지를 베이스로 커스텀
FROM opensearchproject/opensearch:${OPENSEARCH_VERSION}

# RUN을 통해 Nori를 베이스 이미지에 설치하여 이미지를 빌드한다.
RUN opensearch-plugin install analysis-nori