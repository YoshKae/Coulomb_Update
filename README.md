# Coulomb ver. 4.x  

Currently, the repository includes the **Coulomb ver. 4.0.0**.  
Coulomb ver. 4.0 is a MATLAB-based application redesigned and reconstructed for the current MATLAB environment based on [Coulomb ver. 3 (Toda et al., 2011)](https://pubs.usgs.gov/of/2011/1060/).  
The software has been significantly extended from the previous version to support the calculation and visualization of **static Coulomb stress changes in both 2D and 3D**.  
While it is expected to run on MATLAB 2024a or later, it is more stable when used with MATLAB 2025a or newer.  
  
Bugs may be discovered and fixed, and new features may be added.  
**Please check the update information regularly.**  

### Update information 
- [ver. 4.0.0](https://github.com/YoshKae/Coulomb_ver4/releases/tag/v4.0.0) — 2026-02-08 **Latest**
- ver. 4.0.1 — under development

### Important Notice 
**Before running the application, please ensure that the following MATLAB add-ons are installed:**  
**Required for core functions**  
- [Mapping Toolbox](https://jp.mathworks.com/products/mapping.html)  
- [Image Processing Toolbox](https://jp.mathworks.com/products/image-processing.html)

**Required only for optional earthquake catalog analysis**  
- [Curve Fitting Toolbox](https://jp.mathworks.com/products/curvefitting.html)  
  (used for statistical analysis with the [ISC Earthquake Toolbox](https://www.isc.ac.uk/projects/matlab/))  

Although the calculation results are generally reliable, unstable behavior has been observed under certain conditions.  
We are continuing to debug these issues; please refer to future updates of coulomb.mlapp for improvements.  

### Repository Structure  
- `coulomb.mlapp` — Main MATLAB App Designer application file  
- `input_files/` — Directory for input files such as finite fault data used in analyses  
- `input_overlay_files/` — Folder containing overlay files used for analysis  
- `other_functions/` — Optional function directory; generally not required for normal use  
- `output_cou_files/`, `output_data_files/` — Directories where calculation results are saved  
- `preferences/`, `slides/` — Configuration files used while the app is running  

### How to Run  
1. Download all files contained in the Coulomb_ver4_beta directory, or download **[coulomb_ver4_beta.zip](https://github.com/YoshKae/Coulomb_ver4/blob/main/coulomb_ver4_beta.zip)** and extract it. If you use the ZIP file, please also follow step (*1) below.  
2. Open the directory "coulomb_ver4_beta" in MATLAB. (It is sufficient to open the directory that contains coulomb.mlapp.)
3. If you want to update the version of the included `coulomb.mlapp`, please download the corresponding file from the [Releases](https://github.com/YoshKae/Coulomb_ver4/releases) of the target version and replace the existing `coulomb.mlapp` file.  
4. In the MATLAB Command Window, type **coulomb** to launch the software.  
5. Input source faults and receiver faults via the **Open/Save → Open Input File** menu.  
6. Select the desired function mode (e.g., *Coulomb stress change*, *Displacement vectors*, *Strain field*).  
7. Executes calculations according to window instructions.  

(*1) Coastline data required  
Due to GitHub file size limitations, the files required for generating coastline data within the application are not included in this repository.  
Please download the publicly available coastline dataset provided by NOAA (National Oceanic and Atmospheric Administration) from the following link:  
`https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/gshhg-shp-2.3.7.zip`  

After downloading, extract the ZIP file and move the extracted contents directly into the **`input_overlay_files/`** directory.  

### Future Updates  
- Expansion of documentation and help systems  
- Full compatibility with MATLAB 2024a and later  
- Complete integration of the ISC Earthquake Toolbox  
- Functions to retrieve earthquake catalogs published by various institutions  
- Enhanced in-app creation tools for overlay data  
- Map visualization functions  
- Bug fixes and other improvements  

### Support 
For questions, bug reports, feature requests, and general feedback, please use the **[Issues section](https://github.com/YoshKae/Coulomb_ver4/issues)**  of this GitHub repository. 

This software is also introduced on the **[Temblor, Inc.](https://temblor.net/)** website.  
Please refer to **[this page](https://temblor.net/earthquake-insights/introducing-coulomb-4-0-enhanced-stress-interaction-and-deformation-software-for-research-and-teaching-17066/)** for an overview and related information.


### Contact  
For collaboration inquiries or direct contact, please reach out by email:  
  **Kaede Yoshizawa**   
  `Email: yoshizawa.kaede.q1@dc.tohoku.ac.jp`  


This repository was created on August 8, 2025, to share the development and editorial progress of Coulomb ver. 4.x.

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

# Coulomb ver. 4.x  

現在、**Coulomb ver. 4.0.0**を収録しています。  
Coulomb ver. 4.0 は、[Coulomb ver. 3 (Toda et al., 2011)](https://pubs.usgs.gov/of/2011/1060/)を基盤として、現行の MATLAB 環境向けに再設計・再構築された、静的クーロン応力変化を 2 次元および 3 次元で計算・可視化するための MATLAB ベースのアプリケーションであり、従来版から大幅に拡張されたものです。  
<br>
MATLAB 2024a 以降で動作するはずですが、2025a 以降での使用がより安定しています。  


## 重要

新たに発見されたバグが修正される可能性や、新機能が追加される場合があります.  
**アップデート情報を確認するようにしてください。**  

### アップデート情報
- [ver. 4.0.0](https://github.com/YoshKae/Coulomb_ver4/releases/tag/v4.0.0) — 2026-02-08 **最新**
- ver. 4.0.1 — 開発中

### 今後のアップデート予定  
- ドキュメントおよびヘルプシステムの拡充  
- MATLAB 2024a 以降への完全対応  
- ISC Earthquake Toolboxの完全統合  
- 諸機関の公開する地震カタログの取得機能  
- オーバーレイデータのアプリ内作成機能の拡充  
- 地図表示機能  
- その他バグなどの修正
<br>
<br>
**アプリケーションを実行する前に、以下の MATLAB アドオンがインストールされていることを確認してください。**  
### 必須（基本機能）  
- [Mapping Toolbox](https://jp.mathworks.com/products/mapping.html)  
- [Image Processing Toolbox](https://jp.mathworks.com/products/image-processing.html)

### 任意（特定の解析機能のみ）  
- [Curve Fitting Toolbox](https://jp.mathworks.com/products/curvefitting.html)  
  （[ISC Earthquake Toolbox](https://www.isc.ac.uk/projects/matlab/) を用いた地震カタログの統計解析時に使用） 

<br>
計算結果自体は概ね信頼できるものですが、特定の条件下で不安定な挙動が確認されています。  
本件については引き続きデバッグを進めており、今後の coulomb.mlapp の更新をご確認ください。  
<br>
<br>

## リポジトリ構成  
- `coulomb.mlapp` — MATLAB App Designer によるメインアプリケーションファイル  
- `input_files/` — 解析に使用する有限地震断層モデルの入力ファイル格納用フォルダ。  
- `input_overlay_files/` — 解析時に重ね描きするオーバーレイ用ファイルのフォルダ  
- `other_functions/` — オプション的な関数フォルダ，基本的に使用しません。  
- `output_cou_files/`, `output_data_files/` — 計算結果が保存されるフォルダ  
- `preferences/`, `slides/` — アプリ実行中に使用される設定ファイル  
<br>
<br>

## 実行方法  
1. Coulomb_ver4_betaのディレクトリに含まれるファイルをダウンロードする、もしくは **[coulomb_ver4_beta.zip](https://github.com/YoshKae/Coulomb_ver4/blob/main/coulomb_ver4_beta.zip)** をダウンロードし解凍してください。zipファイルからの場合は（※1）の手順も行ってください。  
2. MATLAB 上でディレクトリ "coulomb_ver4_beta" を開いてください。coulomb.mlappが格納されているディレクトリを開いた状態であれば問題ありません。
3. 格納されているcoulomb.mlappのバージョンを変更する場合には、[リリースノート](https://github.com/YoshKae/Coulomb_ver4/releases)から当該バージョンのcoulomb.mlappをダウンロードし、ファイルを差し替えてください。  
4. MATLAB コマンドウィンドウから "coulomb" と入力し、ソフトウェアを実行します。  
5. メニューの **Open/Save → Open Input File** から、震源断層データおよびレシーバー断層データを読み込みます。  
6. 実行したい機能モードを選択します。 (e.g., *Coulomb stress change*, *Displacement vectors*, *Strain field*).    
7. ウィンドウ上の指示に従って計算を実行してください。  

（※1）海岸線データの取得  
GitHubのサイズ制限の問題で、アプリ内で海岸線データの作成に利用するファイルが含まれていません。  
NOAA（米国海洋大気庁）の公開しているデータを以下のリンクからダウンロードしてください。  
`https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/gshhg-shp-2.3.7.zip`  
ダウンロードしたzipファイルを解凍し、 **`input_overlay_files/`** のディレクトリ内にそのまま移動してください。  



## サポート　
ご質問、不具合報告、機能追加のご要望、その他フィードバックについては、本 GitHub リポジトリの **[Issues](https://github.com/YoshKae/Coulomb_ver4/issues)** よりご連絡ください。　　

また、本ソフトウェアは以下の **[Temblor, Inc.](https://temblor.net/)** のホームページでも紹介されています。  
概要や関連情報については、 **[こちら](https://temblor.net/earthquake-insights/introducing-coulomb-4-0-enhanced-stress-interaction-and-deformation-software-for-research-and-teaching-17066/)** もあわせてご参照ください。  

## 連絡先  
共同研究や直接のご連絡は、以下のアドレスまでお願いいたします。  
  **吉澤　楓**  
  `Email: yoshizawa.kaede.q1@dc.tohoku.ac.jp`  
<br>
<br>
本リポジトリは、Coulomb ver. 4.x の開発・編集状況を共有する目的で、2025年8月8日に作成されました。  
