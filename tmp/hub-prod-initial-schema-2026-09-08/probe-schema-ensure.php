<?php
// Définitions réelles uniquement ; double mémoire strict, aucune connexion DB.
$cases = array('conforme', 'ancien_enum', 'nullable', 'defaut', 'extra', 'ordre_enum', 'casse_valeur', 'lecture_echouee', 'colonne_absente', 'metadata_partielle');
if (!isset($argv[1])) {
    foreach ($cases as $case) {
        passthru(escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($case), $code);
        if ($code !== 0) { exit($code); }
    }
    exit(0);
}
$case = $argv[1];
if (!in_array($case, $cases, true)) { exit(2); }
final class SchemaProbeResult {
    public $num_rows = 1;
    private $row;
    public function __construct($row = null) { $this->row = $row; }
    public function fetch_assoc() { return $this->row; }
}
final class SchemaProbeDb {
    public $ddl = array();
    public $status_reads = 0;
    public $case;
    public function real_escape_string($s) { return addslashes($s); }
    public function query($sql) {
        if ($sql === "SHOW COLUMNS FROM `games_hubs_players_sessions` WHERE Field = 'status'") {
            $this->status_reads++;
            $row = array('Field' => 'status', 'Type' => "enum('created','active','left','completed','failed')", 'Null' => 'NO', 'Default' => 'created', 'Extra' => '');
            switch ($this->case) {
                case 'ancien_enum': $row['Type'] = "enum('created','active','completed','failed')"; break;
                case 'nullable': $row['Null'] = 'YES'; break;
                case 'defaut': $row['Default'] = null; break;
                case 'extra': $row['Extra'] = 'INVISIBLE'; break;
                case 'ordre_enum': $row['Type'] = "enum('active','created','left','completed','failed')"; break;
                case 'casse_valeur': $row['Type'] = "enum('CREATED','active','left','completed','failed')"; break;
                case 'lecture_echouee': return false;
                case 'colonne_absente': return new SchemaProbeResult();
                case 'metadata_partielle': unset($row['Type']); break;
            }
            return new SchemaProbeResult($row);
        }
        if (preg_match('/^SHOW (TABLES|COLUMNS) /', $sql)) { return new SchemaProbeResult(); }
        if (preg_match('/^(CREATE|ALTER) TABLE /', $sql)) { $this->ddl[] = $sql; return true; }
        throw new RuntimeException('Requête inattendue : ' . $sql);
    }
}
require dirname(__DIR__, 3) . '/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php';
$db = new SchemaProbeDb(); $db->case = $case; $GLOBALS['mysqli'] = $db;
$expected = in_array($case, array('ancien_enum', 'nullable', 'defaut', 'extra', 'ordre_enum', 'casse_valeur'), true) ? 1 : 0;
app_games_hub_schema_ensure();
$first = count($db->ddl);
app_games_hub_schema_ensure();
if ($first !== $expected || count($db->ddl) !== $expected || $db->status_reads !== 1
    || ($expected && $db->ddl[0] !== "ALTER TABLE `games_hubs_players_sessions` MODIFY `status` enum('created','active','left','completed','failed') NOT NULL DEFAULT 'created'")) {
    fwrite(STDERR, 'FAIL ' . $case . ': ' . json_encode($db) . "\n"); exit(1);
}
echo "PASS $case : premier appel $first DDL ; deuxième appel " . count($db->ddl) . " DDL cumulés.\n";
