<?php 

\defined('_\MSTART') OR \define('_\MSTART', \microtime(true));
try {(function(){
    
    try {

        $this->fn = (object)[];
        
        $this->fn->report = function($ex){
            echo "\033[91m\n"
                .$ex::class.": {$ex->getMessage()}\n"
                ."File: {$ex->getFile()}\n"
                ."Line: {$ex->getLine()}\n"
                ."\033[31m{$ex}\033[0m\n"
            ;
            exit;
        };
        
        $this->fn->dump = function ($d){
            echo "\033[97m"
                ."    "
                .\str_replace("\n","\n    ", \json_encode(
                    $d, 
                    JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES
                ))
                .PHP_EOL
                ."\033[0m"
            ;
        };

        $this->fn->fs_delete = function (string $path) {
            $g = glob($path, (strpos($path,'{') === false) ? 0 : GLOB_BRACE);
            foreach($g as $p){
                if(is_dir($p)){
                    foreach(new \RecursiveIteratorIterator(
                        new \RecursiveDirectoryIterator($p, \RecursiveDirectoryIterator::SKIP_DOTS)
                        , \RecursiveIteratorIterator::CHILD_FIRST
                    ) as $f) {
                        if ($f->isDir()){
                            rmdir($f->getRealPath());
                        } else {
                            unlink($f->getRealPath());
                        }
                    }
                    rmdir($p);
                } else if(file_exists($p)) {
                    unlink($p);
                }
            }
        };
            
        $this->fn->github_transact = function ($url, $is_json = false, $filter = false){
            echo "URL: {$url}\n";
            // Initialize cURL session
            $ch = \curl_init();
            
            // Set the cURL options
            \curl_setopt($ch, CURLOPT_URL, $url);
            \curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            \curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);  // Follow redirects
            \curl_setopt($ch, CURLOPT_USERAGENT, 'PHP');      // Set User-Agent header to avoid 403
            //\curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: token YOUR_ACCESS_TOKEN']); // If repo is private
            
            // Execute the request
            $response = \curl_exec($ch);
            
            // Check for errors
            if (curl_errno($ch)) {
                echo "cURL Error: " . \curl_error($ch);
                return null;
            }
            
            // Close the cURL session
            \curl_close($ch);
            if($is_json === true){
                $data = \json_decode($response, true) ?: [];
                if(!$data){
                    echo "Empty Dataset";
                }
                if(($data['status'] ?? null) == '404'){
                    echo "Repo may not exist - Please check the URL\n";
                }
                1 AND ($this->fn->dump)($data);
                if($filter instanceof \closure){
                    return ($filter)($data);
                } else {
                    return $data;
                }
                return ;
            } else  {
                return $response;
            }
        };
        
        $this->fn->cli_env_var = function(array $assoc) {
            static $I = null; 
            if(\is_null($I)){
                $I = [];
                \register_shutdown_function(function () use(&$I){
                    if($I){
                        \register_shutdown_function(function() use(&$I){
                            $content = '';
                            foreach($I as $k => $v){
                                if(\is_scalar($v)){
                                    $content .= "SET \"$k=$v\"\n";
                                }
                            }
                            \file_put_contents(
                                \trim(getenv('FX__ENV_FILE'),'"'),
                                $content
                            );
                            exit(3);  // Exit with 3 to trigger batch execution
                        });
                    }
                });
            }
            if($assoc){
                $I = \array_replace($I, $assoc);
            } else {
                return $assoc;
            }
        };
        
        $this->fn->config_bat = function($k){
            $x = \is_file($f = \_\FSESS_DIR."/.fw.config.bat")
                ? (function($f){
                    $vars = [];
                    $lines = \file($f, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
                    foreach ($lines as $line) {
                        if (preg_match('/^SET\s+FW__(\w+)=?(.*)$/i', $line, $m)) {
                            $vars[$m[1]] = $m[2] ?? '';
                        }
                    }
                    return $vars;
                })($f)
                : []
            ;
            if(\is_string($k)){
                return $x[$k] ?? null;
            } else if(\is_callable($k)){
                ($k)($x);
            } else if(\is_array($k)){
                $x = \array_replace_recursive($x, $k);
            } else {
                throw new \Exception("Invalid argument for config");
            }
            \file_put_contents($f, \implode(
                PHP_EOL, 
                array_map(
                    fn($k, $v) => "SET FW__{$k}={$v}", 
                    array_keys($x), 
                    $x
                )
            ));

            $content = '';
            foreach($x as $k => $v){
                if(\is_scalar($v)){
                    $content .= "SET \"$k=$v\"\n";
                }
            }
            \file_put_contents($f, $content);
        };
        
        $this->fn->config = function($k){
            $x = \is_file($f = \_\FSESS_DIR."/.fw.config.php")
                ? (\is_array($x = include $f) ? $x : [])
                : []
            ;
            if(\is_string($k)){
                return $x[$k] ?? null;
            } else if(\is_callable($k)){
                ($k)($x);
            } else if(\is_array($k)){
                $x = \array_replace_recursive($x, $k);
            } else {
                throw new \Exception("Invalid argument for config");
            }
            \file_put_contents($f,'<?php return '.\var_export($x,true).';');
        };

        $this->fn->path_is_rooted = function($p){
            return $p && ($p[0] == '/' || ($p[1]??'')===':');
        };
        
        $this->fn->my_lib = function($target_name) {
            global $_;
            if($target_name === true){
                echo "LIB Dir: ".($_['LIB']['DIR'] ?? \_\LIB_DIR);
            } else if($target_name === '!!!'){
                ($this->fn->config)(function(&$x){ 
                    unset($x['LIB']['DIR']);
                    unset($x['CLI']['DIR']); 
                });
            } else if(
                ($this->fn->path_is_rooted)($target_name) 
                    ? \is_dir($d = $target_name)
                    : (
                        \is_dir($d = \_\FSESS_DIR.'/'.$target_name)
                        || \is_dir($d = \_\START_DIR.'/'.$target_name)
                    )
            ){
                ($this->fn->config)(function(&$x) use($d){ 
                    $x['LIB']['DIR'] = $d;
                    unset($x['CLI']['DIR']); 
                });
            } else {
                echo "Failed: Module Not Found '{$target_name}'\n";
            }
        };
        
        $this->fn->my_cli = function($target_name) {
            global $_;
            if($target_name === true){
                echo "CLI Dir: ".($_['CLI']['DIR'] ?? \_\LIB_DIR.'/-setup');
            } else if($target_name === '!!!'){
                ($this->fn->config)(function(&$x){ unset($x['CLI']['DIR']); });
            } else if(\is_dir($d = \_\LIB_DIR.'/'.$target_name)){
                ($this->fn->config)(fn(&$x) => $x['CLI']['DIR'] = $d);
            } else {
                echo "Failed: Module Not Found '{$target_name}'\n";
            }
        };
        
        $this->fn->my_setup = function($target_name){
            if($target_name === true){
                $target_name = '-setup';
            }
            if(!\preg_match("#^[\w\-\.]+$#", $target_name,$m)){
                echo "Failed: Invalid target name '{$target_name}'\n";
                return;
            }
            echo "Target Name: {$target_name}\n";
            $target_dir = \_\LIB_DIR.'/'.$target_name;
            echo "Target Dir: {$target_dir}\n";
            if(($d = $_REQUEST['-d'] ?? null) === true){
                ($this->fn->fs_delete)($target_dir);
                echo "Deleted: '{$target_name}' was successfully deleted\n";
                return;
            }
            if(!\is_null($x = $_REQUEST['-i'] ?? null)){
                $execute = true;
                $source_hint = ($x === true)
                    ? (($target_name == '-setup')
                        ? 'klude-org/web-0'
                        : null //* maybe some default source in the future
                    ) 
                    : $x
                ;
            } else if(!\is_null($x = $_REQUEST['-o'] ?? null)){
                $execute = false;
                $source_hint = ($x === true)
                    ? (($target_name == '-setup')
                        ? 'klude-org/web-0'
                        : null //* maybe some default source in the future
                    ) 
                    : $x
                ;
            } else {
                $execute = true;
                if(!\is_dir($target_dir)){
                    echo "Unavailable: '{$target_name}' does not exist";
                    return;
                }
                if(!\is_file($f = "{$target_dir}/.installed.json")){
                    echo "Unavailable: '{$target_name}' is not an installed module";
                    return;
                }
                ($this->fn->dump)(\json_decode(\file_get_contents($f),true));
                return;
            }
            
            echo "Source Hint: {$source_hint}\n";
            $version_hint = (($v = $_REQUEST['-v'] ?? null) === true) ? '0' : $v;
            echo "Version Hint: {$version_hint}\n";
            if(!$source_hint){
                echo "Failed: Invalid Source\n";
                return;
            }
            if(\preg_match("#^(?<mod_host>[^/]+)/(?<mod_owner>[^/]+)/(?<mod_repo>[^/]+)$#", $source_hint,  $m)){
                
            } else if(\preg_match("#^(?<mod_owner>[^/]+)/(?<mod_repo>[^/]+)$#", $source_hint,  $m)){
                $mod_host = 'github';
            } else if(\preg_match("#^(?<mod_repo>[^/]+)$#", $source_hint,  $m)){
                $mod_host = 'github';
                $mod_owner = 'klude-org';
            }
            \extract($m = \array_filter($m, fn($k) => !is_numeric($k), ARRAY_FILTER_USE_KEY));
            $mod_name = \str_replace('-','_',"{$mod_owner}__{$mod_repo}");
            $mod_repo = 'fw-mod-'.$mod_repo;
            $mod_file = \_\LOCAL_DIR.'/temp-'.uniqid().'.zip';
            \is_dir($d = \dirname($mod_file)) OR \mkdir($d, 0777, true) OR (function($d){ 
                throw new \Exception("Failed to create directory: $d");
            })($d);
            
            if(\is_null($version_hint)){
                if(!($zipball_url = 
                    ($this->selected_tag = ($this->fn->github_transact)(
                        "https://api.github.com/repos/{$mod_owner}/{$mod_repo}/releases/latest", 
                        true
                    ))['zipball_url'] ?? null
                )){
                    echo "Failed: Unable to get source url of the latest release\n";
                    return;
                }
            } else if(\is_numeric($version_hint)){
                if(!($zipball_url = 
                    ($this->selected_tag = ($this->fn->github_transact)(
                        "https://api.github.com/repos/{$mod_owner}/{$mod_repo}/tags", 
                        true,
                        fn($tags) => $tags[(int) $version_hint]
                    ))['zipball_url'] ?? null
                )){
                    echo "Failed: Unable to get source url from tag index '{$version_hint}'\n";
                    return;
                }
            } else {
                if(!($zipball_url = 
                    ($this->selected_tag = ($this->fn->github_transact)(
                        "https://api.github.com/repos/{$mod_owner}/{$mod_repo}/tags", 
                        true,
                        fn($tags) => current(array_filter($tags, fn($tag) => $tag['name'] == $version_hint))
                    ))['zipball_url'] ?? null
                )){
                    echo "Failed: Unable to get source url from tag name '{$version_hint}'\n";
                    return;
                }
            }
            echo "Source: {$zipball_url}\n";
            if(!$execute){
                return;
            }
            echo "Downloading ...\n";
            if(!($contents = ($this->fn->github_transact)($zipball_url))){
                return;
            }
            if(\file_put_contents($mod_file, $contents) === false){
                echo "\033[91mError Downloading Module.\033[0m\n";
                return;
            }
            echo "\033[92mModule Downloaded Successfully.\033[0m\n";
            try {
                if (($zip = new \ZipArchive)->open($mod_file) !== true) {
                    echo "Failed to open ZIP file.\n";
                    return;
                }
                $sub_folder = \substr($s = $zip->getNameIndex(0), 0, \strpos($s, '/'));
                \is_dir($d = \dirname($target_dir)) OR \mkdir($d, 0777, true) OR (function($d){ 
                    throw new \Exception("Failed to create directory: $d");
                })($d);
                ($this->fn->fs_delete)($target_dir);
                $zip->extractTo($temp = \_\LOCAL_DIR.'/temp-'.uniqid());
                if(\is_dir($x = $temp.'/'.$sub_folder.'/src')){
                    \rename($x, $target_dir);
                    \file_put_contents(
                        "{$target_dir}/.installed.json",
                        \json_encode($this->selected_tag, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
                    );
                    if(\is_file($f = "{$target_dir}/.setup.php")){
                        (function($f){ include $f; })($f);
                        echo "\n";
                    }
                    echo "Module Installed Successfully\n";
                } else {
                    echo "Failed: Module doesn't have src directory\n";
                }
                ($this->fn->fs_delete)($temp); 
            } finally {
                $zip->close();
                \unlink($mod_file);
            }
        };

        global $_;
        (isset($_) && \is_array($_)) OR $_ = [];
        
        \define('_\START_FILE', \str_replace('\\','/', __FILE__));
        \define('_\START_DIR', \dirname(\_\START_FILE));
        \define('_\FSESS_DIR', \str_replace('\\','/', \getenv('FW__SESS_DIR') ?: \getcwd()));
        \define('_\INCP_DIR', \str_replace('\\','/', \dirname($_SERVER['SCRIPT_FILENAME'])));
        \define('_\LOCAL_DIR', \_\INCP_DIR."/.local");
        (\is_file($f = \_\FSESS_DIR."/.fw.config.php")) AND ($_ = \array_replace($_, \is_array($x = include $f) ? $x : []));
        \define('_\LIB_DIR', $_['LIB']['DIR'] ?? null ?: \str_replace('\\','/',__DIR__.'/--fw'));
        \define('_\CLI_DIR', ($_['CLI']['DIR'] ?? null ?: \_\LIB_DIR.'/-setup'));
        \define('_\VND_DIR', \_\LIB_DIR.'/-vnd');
        
        \set_include_path(
            (\is_dir(\_\CLI_DIR) ? \_\CLI_DIR.PATH_SEPARATOR : '').
            \_\VND_DIR.PATH_SEPARATOR. //* this should always be there even if the dir is not present
            \get_include_path()
        );
        \spl_autoload_extensions('-#.php,/-#.php');
        \spl_autoload_register();
        \set_exception_handler(function($ex){
            ($this->fn->report)($ex);
            exit();
        });
        \set_error_handler(function($severity, $message, $file, $line){
            try {
                throw new \ErrorException(
                    $message, 
                    0,
                    $severity, 
                    $file, 
                    $line
                );
            } catch (\Throwable $ex) {
                ($this->fn->report)($ex);
                exit;
            }
        });
        
        $_REQUEST = (function(){
            $parsed = [];
            $key = null;
            $args = \array_slice($argv = $_SERVER['argv'] ?? [], 1);
            foreach ($args as $arg) {
                if ($key !== null) {
                    $parsed[$key] = $arg;
                    $key = null;
                } else if(\str_starts_with($arg, '-')){
                    if(\str_ends_with($arg, ':')){
                        $key = \substr($arg,0,-1);
                    } else if(\str_contains($arg,':')) {
                        [$k, $v] = \explode(':', $arg);
                        $parsed[$k] = $v;
                    } else {
                        $parsed[$arg] = true;
                    }
                } else {
                    $parsed[] = $arg;
                }
            }
            if ($key !== null) {
                $parsed[$key] = true;
            }
            return $parsed;
        })();
        
        ($_REQUEST['--verbose'] ?? null) AND ($this->fn->dump)([
            'CONFIG' => $GLOBALS['_'] ?? null,
            'TSP' => \explode(PATH_SEPARATOR,get_include_path()),
            'CONST' => \get_defined_constants(true)['user'],
        ]);
        
        if(!\is_null($p = $_REQUEST['--my-setup'] ?? null)){
            return function() use($p){ 
                ($this->fn->my_setup)($p);
            };
        } else if(!\is_null($p = $_REQUEST['--my-cli'] ?? null)){
            return function() use($p){ 
                ($this->fn->my_cli)($p);
            };
        } else if(!\is_null($p = $_REQUEST['--my-lib'] ?? null)){
            return function() use($p){ 
                ($this->fn->my_lib)($p);
            };
        } else {
            $intfc = 'fw';
            $path = \trim('__/'.\trim($_REQUEST[0] ?? '', '/'), '/');
            if(
                ($file = \stream_resolve_include_path("{$path}/-@{$intfc}.php"))
                || ($file = \stream_resolve_include_path("{$path}-@{$intfc}.php"))
            ){
                return (function() use($file){
                    (function(){
                        foreach(\explode(PATH_SEPARATOR,get_include_path()) as $d){
                            \is_file($f = "{$d}/.functions.php") AND include_once $f;
                        }
                    })();
                    include $file;
                })->bindTo($GLOBALS['--CTLR'] = (object)[]);
            } else {
                throw new \Exception("Not Found: ".($_REQUEST[0] ?? "/"));
            }
        }
    } catch (\Throwable $ex) {
        return function() use($ex){
            ($this->fn->report)($ex);
        };
    }
})->bindTo((object)[])()(); } catch (\Throwable $ex) {
    echo "\033[91m\n"
        .$ex::class.": {$ex->getMessage()}\n"
        ."File: {$ex->getFile()}\n"
        ."Line: {$ex->getLine()}\n"
        ."\033[31m{$ex}\033[0m\n"
    ;
}


