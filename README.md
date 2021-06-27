Github Release를 토대로 첨부된 `deploy-src.tar` 파일을 지정한 호스트에 접속해서 덮어씌우는 파이프 라인

해당 호스트에 접속해서 git pull origin develop 을 통해서 소스코드를 최신으로 변경

```yml
name: 🚛 hyeonServer deploy
on:
  release:
    types: [published]

jobs:
  asset:
    name: 🗳 릴리즈 `deploy-src.tar` 다운로드 & 호스트 overwrite
    runs-on: ubuntu-latest
    steps:
    - name: 🚚 Get release deploy-src code or file, img, etc...
      uses: dsaltares/fetch-gh-release-asset@master
      with:
        repo: "${{ github.repository }}"
        version: "tags/${{ github.event.release.tag_name }}"
        file: "deploy-src.tar"
        target: "deploy-src.tar"
        token: ${{ secrets.TOKEN }}
        
    - name: 🗳 Create @sync folder and tar Unzip
      run: |
        mkdir @sync
        tar xvf deploy-src.tar -C ./@sync
        rm deploy-src.tar
    
    - name: 📂 Sync files to Server
      uses: AEnterprise/rsync-deploy@v1.0
      env:
        DEPLOY_KEY: ${{ secrets.HYEONSERVER_KEY }}
        SERVER_PORT: ${{ secrets.HYEONSERVER_RSYNC_PORT }}
        FOLDER: "./@sync/"
        ARGS: "-rltgoDzvO --ignore-times"
        SERVER_IP: ${{ secrets.HYEONSERVER_HOST }}
        USERNAME: ${{ secrets.HYEONSERVER_USERNAME }}
        SERVER_DESTINATION: "/volume1/docker/${{ secrets.PROJECT_TYPE }}/${{ secrets.PROJECT_DIR }}"

  source:
    name: 📮 Github 소스코드로 업데이트 `git pull origin develop`
    runs-on: ubuntu-latest
    steps:

    - name: executing remote ssh commands using password
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.HYEONSERVER_HOST }}
        username: ${{ secrets.HYEONSERVER_USERNAME }}
        key: ${{ secrets.HYEONSERVER_KEY }}
        port: ${{ secrets.HYEONSERVER_SSH_PORT }}
        script: |
          cd ${{ secrets.PROJECT_TYPE }}/${{ secrets.PROJECT_DIR }}
          git stash
          git pull origin develop
```

해당 저장소는 위의 

🗳 릴리즈 `deploy-src.tar` 다운로드 & 호스트 overwrite

부분을 Docekrfile, sh로 마이그레이션