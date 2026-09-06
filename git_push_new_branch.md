#本地分支：
#* feature/supabase （✅当前正在工作的分支，星号代表激活）
#  master

#远程分支(git branch -r)：
#origin/HEAD -> origin/master
#origin/master

#把本地 feature/supabase 推送到远程（新建远程分支）
git push -u origin feature/supabase

#切回 master 分支
git checkout master

#把 feature/supabase 的改动合并到 master（开发完功能后）
git checkout master
git pull origin master   #先拉取远程最新master
git merge feature/supabase
git push origin master

