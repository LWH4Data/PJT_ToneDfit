"""RAG 챗봇 체인 구현"""
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from app.libraries.llm_client import get_llm

# 시스템 프롬프트
SYSTEM_PROMPT = """당신은 패션 의류 쇼핑몰의 전문 AI 어시스턴트입니다.
사용자의 질문에 친절하고 정확하게 답변하며, 다음과 같은 역할을 수행합니다:

1. 의류 검색 도움: 사용자의 자연어 질문을 이해하고 적절한 의류 상품을 추천합니다.
2. 스타일링 조언: 날씨, 상황, 취향에 맞는 코디 및 스타일을 제안합니다.
3. 상품 정보 Q&A: 제공된 상품 정보를 바탕으로 사용자의 질문에 답변합니다.
4. 트렌드 정보 제공: 인기 검색어와 트렌드를 바탕으로 유행하는 스타일을 안내합니다.

답변 가이드라인:
- 친절하고 자연스러운 한국어로 답변하세요.
- 절대로 마크다운 문법을 사용하지 마세요: **, __, *, _, ##, -, `, ~~ 등 모든 특수문자를 사용하지 마세요.
- 상품명이나 브랜드명을 언급할 때 어떤 특수문자도 추가하지 마세요. 순수한 텍스트로만 작성하세요.
- 제공된 컨텍스트(상품 정보, 인기 검색어)를 최대한 활용하세요.
- 상품을 추천할 때는 구체적인 이유를 함께 설명하세요.
- 컨텍스트에 없는 정보는 추측하지 말고, 없다고 정직하게 답변하세요.
- 날씨 정보가 제공되면 체감온도에 맞는 옷을 추천하세요.
"""

# 컨텍스트 포함 프롬프트
CONTEXT_PROMPT = """
{weather_context}
[검색된 상품 정보]
{products_context}

[인기 검색어]
{trending_keywords}

[사용자 질문]
{question}

위 정보를 참고하여 사용자의 질문에 답변해주세요."""

# 일반 프롬프트 (컨텍스트 없음)
NO_CONTEXT_PROMPT = """
[사용자 질문]
{question}

패션 전문가로서 사용자의 질문에 답변해주세요."""


def get_rag_chain():
    """RAG 체인 생성"""
    llm = get_llm()

    # 프롬프트 템플릿
    prompt = ChatPromptTemplate.from_messages([
        ("system", SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="chat_history", optional=True),
        ("human", "{formatted_prompt}")
    ])

    # 체인 구성
    chain = (
        RunnablePassthrough()
        | prompt
        | llm
        | StrOutputParser()
    )

    return chain


def format_products_context(products: list[dict]) -> str:
    """상품 리스트를 컨텍스트 문자열로 포맷"""
    if not products:
        return "검색된 상품이 없습니다."

    context_parts = []
    for idx, product in enumerate(products, 1):
        product_info = f"""
{idx}. {product['name']}
   브랜드: {product['brand']}
   가격: {product['original_price']:,}원
   카테고리: {product.get('large_category', 'N/A')} > {product.get('small_category', 'N/A')}
   색상: {', '.join(product.get('colors', []))}
   소재: {', '.join(product.get('fabrics', []))}
"""
        context_parts.append(product_info.strip())

    return "\n\n".join(context_parts)


def format_trending_keywords(keywords: list[dict]) -> str:
    """인기 검색어를 컨텍스트 문자열로 포맷"""
    if not keywords:
        return "인기 검색어 정보가 없습니다."

    keyword_list = [f"{k['rank']}. {k['keyword']} (검색 {k['search_count']}회)"
                   for k in keywords]
    return "\n".join(keyword_list)


def create_formatted_prompt(
    question: str,
    products: list[dict] | None = None,
    trending_keywords: list[dict] | None = None,
    weather_info: str | None = None
) -> str:
    """질문과 컨텍스트를 포맷하여 최종 프롬프트 생성"""
    has_context = bool(products or trending_keywords or weather_info)

    if has_context:
        products_context = format_products_context(products or [])
        keywords_context = format_trending_keywords(trending_keywords or [])
        weather_context = ""
        if weather_info:
            weather_context = f"[날씨 정보]\n{weather_info}\n\n"

        return CONTEXT_PROMPT.format(
            weather_context=weather_context,
            products_context=products_context,
            trending_keywords=keywords_context,
            question=question
        )
    else:
        return NO_CONTEXT_PROMPT.format(question=question)
