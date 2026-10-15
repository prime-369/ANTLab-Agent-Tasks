"""离线导出一条已审核的运行；去除 endpoint，保留模型原始响应和实际消息。"""
import hashlib
import json
import sys
from pathlib import Path


def main():
    source = Path(sys.argv[1])
    raw = source.read_bytes()
    record = json.loads(raw)
    if record['case_id'] != 'D01' or record['split'] != 'dev':
        raise ValueError('本轮只允许导出 D01 开发记录')
    config = record['config']
    if set(config) - {'provider', 'endpoint', 'model', 'parameters', 'timeout_seconds'}:
        raise ValueError('存在未审核配置字段，停止导出')
    config.pop('endpoint', None)
    record['public_export'] = {
        'removed_config_fields': ['endpoint'],
        'original_file_sha256': hashlib.sha256(raw).hexdigest(),
        'note': '仅去除配置中的 endpoint；messages、response、usage、状态均保留。',
    }
    folder = Path(__file__).resolve().parents[1] / 'runs' / 'basic'
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / source.name
    if target.exists():
        raise FileExistsError('公开记录已存在，不覆盖')
    target.write_text(json.dumps(record, ensure_ascii=False, indent=2), encoding='utf-8')
    print(target)


if __name__ == '__main__':
    main()
