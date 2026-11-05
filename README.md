# scuba-gitops — deploy do Scuba Dive Log

Repositório GitOps da demo de CI/CD no NKP. Aqui fica o que roda no cluster: o Helm
chart `scuba` e os valores de cada ambiente. O Flux embarcado do NKP e o Argo CD
observam este repositório e aplicam as mudanças.

O código do app fica em [`scuba-app`](https://github.com/miriamcsn/scuba-app). O CI de
lá publica as imagens no Harbor e faz um commit aqui só para atualizar as tags.

## Estrutura

```
charts/scuba/         Helm chart: backend, frontend, MySQL (StatefulSet + volume), Ingress
envs/demo/values.yaml registry, tags das imagens (atualizadas pelo CI) e ajustes do ambiente
flux/                 GitRepository + HelmRelease para o Flux embarcado do NKP
argocd/               Application do Argo CD
```

## Antes do primeiro uso

1. Troque `<HARBOR_HOST>` em `envs/demo/values.yaml` pelo endereço do Harbor do NKP.
2. Rode o CI do `scuba-app` uma vez, para publicar as imagens e gravar as tags reais.
   Com a tag `initial`, os pods do backend e do frontend ficam em ImagePullBackOff.
3. Se o projeto `scuba` do Harbor for privado, crie um Secret docker-registry no
   namespace do app e liste-o em `imagePullSecrets` no `envs/demo/values.yaml`.

## CD com o Flux embarcado do NKP

Na UI do NKP: Project > Continuous Deployment (CD) > Add GitOps Source, com:

- Repository URL: `https://github.com/miriamcsn/scuba-gitops`
- Branch: `main`
- Path: `./flux`

O NKP aplica a pasta `flux/` no namespace do projeto. O `GitRepository` dessa pasta
busca o chart e os valores, e o `HelmRelease` instala o release `scuba`.

Sem a UI, o mesmo resultado com: `kubectl apply -n demo-flux -f flux/`

## CD com o Argo CD

```bash
kubectl apply -f argocd/application.yaml
```

O Argo CD instala o release `scuba` no namespace `demo-argo`, usando
`charts/scuba/values.yaml` e, por cima, `envs/demo/values.yaml`.

Rode um CD por vez: os dois Ingress não têm host, então disputariam o mesmo caminho no Traefik.

## Cena do NKP Insights

Antes da cena, o Insights aponta os containers sem `securityContext`. Para corrigir pelo
Git, descomente os blocos `securityContext` de `envs/demo/values.yaml`, faça commit e push.
O CD aplica e os achados do backend e do frontend somem na próxima análise. Achados do
MySQL e de sistema de arquivos somente leitura continuam, de propósito: rendem conversa
sobre o que corrigir a seguir.

## Credenciais

As senhas do MySQL estão em texto puro nos Secrets do chart, apenas para a demo. Em
produção, use Sealed Secrets ou External Secrets.
